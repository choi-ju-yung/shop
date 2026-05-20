package com.example.demo.util;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.File;
import java.util.UUID;

@Service
@Slf4j
public class FileStorageService {

    @Autowired(required = false)
    private S3Client s3Client;

    @Value("${oci.storage.endpoint:}")
    private String endpoint;

    @Value("${oci.storage.bucket:}")
    private String bucket;

    @Value("${oci.storage.region:}")
    private String region;

    @Value("${oci.storage.namespace:}")
    private String namespace;

    @Value("${app.upload.dir:C:/upload}")
    private String uploadDir;

    /**
     * OCI 설정이 있으면 OCI에, 없으면 로컬에 저장한다.
     * @param folder 저장 폴더 (예: "productRegist", "profile", "banner")
     * @param file   업로드할 파일
     * @return 접근 가능한 URL (OCI: https://..., 로컬: /upload/...)
     */
    public String upload(String folder, MultipartFile file) {
        if (endpoint != null && !endpoint.isBlank()) {
            return uploadToOci(folder, file);
        }
        return uploadToLocal(folder, file);
    }

    private String uploadToOci(String folder, MultipartFile file) {
        String ext = getExt(file.getOriginalFilename());
        String objectKey = folder + "/" + UUID.randomUUID() + ext;
        try {
            s3Client.putObject(
                    PutObjectRequest.builder()
                            .bucket(bucket)
                            .key(objectKey)
                            .contentType(file.getContentType())
                            .build(),
                    RequestBody.fromBytes(file.getBytes())
            );
        } catch (Exception e) {
            log.error("OCI 파일 업로드 실패 key={}: {}", objectKey, e.getMessage());
            throw new RuntimeException("파일 업로드에 실패했습니다.", e);
        }
        return "https://objectstorage." + region + ".oraclecloud.com/n/"
                + namespace + "/b/" + bucket + "/o/" + objectKey;
    }

    private String uploadToLocal(String folder, MultipartFile file) {
        String ext = getExt(file.getOriginalFilename());
        String savedName = UUID.randomUUID() + ext;
        File dir = new File(uploadDir + "/" + folder);
        if (!dir.exists()) dir.mkdirs();
        try {
            file.transferTo(new File(dir, savedName));
        } catch (Exception e) {
            log.error("로컬 파일 저장 실패: {}", e.getMessage());
            throw new RuntimeException("파일 저장에 실패했습니다.", e);
        }
        return "/upload/" + folder + "/" + savedName;
    }

    private String getExt(String filename) {
        return filename.substring(filename.lastIndexOf(".")).toLowerCase();
    }
}
