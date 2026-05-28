package com.example.demo.productregist;

import com.example.demo.product.service.ProductEsService;
import com.example.demo.product.vo.Product;
import com.example.demo.product.vo.ProductFile;
import com.example.demo.productregist.dao.ProductRegistDao;
import com.example.demo.productregist.service.ProductRegistService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProductRegistServiceTest {

    @Mock
    ProductRegistDao productRegistDao;

    @Mock
    ProductEsService productEsService;

    @InjectMocks
    ProductRegistService productRegistService;

    // ───────────────────────────────────────────
    // insertProduct
    // ───────────────────────────────────────────

    @Test
    @DisplayName("상품 등록 - DB insert, 파일 insert, ES 인덱싱 모두 호출")
    void insertProduct_success() {
        ProductFile file = ProductFile.builder()
                .filePath("/img/product/test.jpg")
                .isMain(true)
                .build();

        Product product = Product.builder()
                .productId(1L)
                .title("테스트 상품")
                .price(10000)
                .productFiles(List.of(file))
                .build();

        productRegistService.insertProduct(product);

        verify(productRegistDao).insertProduct(product);
        verify(productRegistDao).insertProductFile(file);
        verify(productEsService).indexProduct(product);
    }

    @Test
    @DisplayName("상품 등록 - isMain 파일 경로가 mainFilePath에 세팅됨")
    void insertProduct_mainFilePathSet() {
        ProductFile mainFile = ProductFile.builder()
                .filePath("/img/product/main.jpg")
                .isMain(true)
                .build();
        ProductFile subFile = ProductFile.builder()
                .filePath("/img/product/sub.jpg")
                .isMain(false)
                .build();

        Product product = Product.builder()
                .productId(1L)
                .title("테스트 상품")
                .productFiles(List.of(subFile, mainFile))
                .build();

        productRegistService.insertProduct(product);

        assertThat(product.getMainFilePath()).isEqualTo("/img/product/main.jpg");
    }

    @Test
    @DisplayName("상품 등록 - DB 오류 시 RuntimeException 발생")
    void insertProduct_dbError_throwsRuntimeException() {
        Product product = Product.builder()
                .productId(1L)
                .title("오류 상품")
                .productFiles(List.of())
                .build();

        doThrow(new RuntimeException("DB 오류")).when(productRegistDao).insertProduct(any());

        assertThatThrownBy(() -> productRegistService.insertProduct(product))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("상품 등록 중 오류 발생");

        verify(productEsService, never()).indexProduct(any());
    }

    // ───────────────────────────────────────────
    // deleteProduct
    // ───────────────────────────────────────────

    @Test
    @DisplayName("상품 삭제 - 정상 삭제 시 위시리스트, soft delete, ES 제거 호출")
    void deleteProduct_success() {
        when(productRegistDao.selectSellerNoByProductId(1L)).thenReturn(100L);

        productRegistService.deleteProduct(1L, 100L);

        verify(productRegistDao).deleteWishlistByProductId(1L);
        verify(productRegistDao).softDeleteProduct(1L);
        verify(productEsService).removeProduct(1L);
    }

    @Test
    @DisplayName("상품 삭제 - 존재하지 않는 상품이면 IllegalArgumentException")
    void deleteProduct_notFound() {
        when(productRegistDao.selectSellerNoByProductId(99L)).thenReturn(null);

        assertThatThrownBy(() -> productRegistService.deleteProduct(99L, 100L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("존재하지 않는 상품입니다.");
    }

    @Test
    @DisplayName("상품 삭제 - 본인 상품이 아니면 SecurityException")
    void deleteProduct_noPermission() {
        when(productRegistDao.selectSellerNoByProductId(1L)).thenReturn(100L);

        assertThatThrownBy(() -> productRegistService.deleteProduct(1L, 999L))
                .isInstanceOf(SecurityException.class)
                .hasMessage("삭제 권한이 없습니다.");

        verify(productRegistDao, never()).softDeleteProduct(any());
    }

    // ───────────────────────────────────────────
    // updateTradeStatus
    // ───────────────────────────────────────────

    @Test
    @DisplayName("거래 상태 변경 - SOLD인데 buyerNo 없으면 IllegalArgumentException")
    void updateTradeStatus_soldWithoutBuyer() {
        assertThatThrownBy(() -> productRegistService.updateTradeStatus(1L, 100L, "SOLD", null))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("거래완료 처리 시 구매자를 선택해야 합니다.");
    }

    @Test
    @DisplayName("거래 상태 변경 - 권한 없으면 SecurityException")
    void updateTradeStatus_noPermission() {
        when(productRegistDao.updateTradeStatus(any())).thenReturn(0);

        assertThatThrownBy(() -> productRegistService.updateTradeStatus(1L, 999L, "SALE", null))
                .isInstanceOf(SecurityException.class);
    }

    @Test
    @DisplayName("거래 상태 변경 - SOLD 정상 처리 시 insertTrade 호출")
    void updateTradeStatus_soldSuccess() {
        when(productRegistDao.updateTradeStatus(any())).thenReturn(1);

        productRegistService.updateTradeStatus(1L, 100L, "SOLD", 200L);

        verify(productRegistDao).insertTrade(any());
        verify(productEsService).updateProductStatus(1L, "SOLD");
    }

    @Test
    @DisplayName("거래 상태 변경 - SALE 변경 시 insertTrade 미호출")
    void updateTradeStatus_saleSuccess() {
        when(productRegistDao.updateTradeStatus(any())).thenReturn(1);

        productRegistService.updateTradeStatus(1L, 100L, "SALE", null);

        verify(productRegistDao, never()).insertTrade(any());
        verify(productEsService).updateProductStatus(1L, "SALE");
    }
}
