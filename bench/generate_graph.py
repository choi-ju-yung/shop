"""
채팅 DB vs Redis write-behind 성능 비교 그래프 생성기

사용법:
  1. JMeter로 각 RPS(100/200/300/500/800/1000) 테스트 후 results/ 폴더에 CSV 저장
  2. python generate_graph.py 실행
  3. chat_bench_comparison.png 생성됨

필요 패키지:
  pip install pandas matplotlib numpy
"""

import os
import sys
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

RESULTS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "jmeter", "results")
RPS_LEVELS = [100, 200, 300, 500, 800, 1000]


def calculate_p95(csv_path):
    """JMeter CSV에서 P95 응답시간(ms) 계산"""
    try:
        df = pd.read_csv(csv_path)
        # 성공 요청만 포함
        if "success" in df.columns:
            df = df[df["success"] == True]
        return float(np.percentile(df["elapsed"], 95))
    except Exception as e:
        print(f"  [경고] {csv_path} 읽기 실패: {e}")
        return None


def main():
    os.makedirs(RESULTS_DIR, exist_ok=True)

    db_p95    = {}
    redis_p95 = {}

    print("=" * 50)
    print("  결과 파일 분석 중...")
    print("=" * 50)

    for rps in RPS_LEVELS:
        db_file    = os.path.join(RESULTS_DIR, f"db_{rps}rps.csv")
        redis_file = os.path.join(RESULTS_DIR, f"redis_{rps}rps.csv")

        if os.path.exists(db_file):
            val = calculate_p95(db_file)
            if val is not None:
                db_p95[rps] = val
                print(f"  DB    {rps:4d} RPS → P95: {val:.1f} ms")
        else:
            print(f"  [없음] {db_file}")

        if os.path.exists(redis_file):
            val = calculate_p95(redis_file)
            if val is not None:
                redis_p95[rps] = val
                print(f"  Redis {rps:4d} RPS → P95: {val:.1f} ms")
        else:
            print(f"  [없음] {redis_file}")

    if not db_p95 and not redis_p95:
        print("\n결과 파일이 없습니다.")
        print(f"JMeter 실행 후 results/ 폴더에 CSV를 저장하세요.")
        print(f"예: results/db_100rps.csv, results/redis_100rps.csv")
        sys.exit(1)

    # ── 그래프 그리기 ──────────────────────────────────────
    plt.rcParams["font.family"] = "Malgun Gothic"  # 한글 폰트 (Windows)
    plt.rcParams["axes.unicode_minus"] = False

    fig, ax = plt.subplots(figsize=(11, 7))
    fig.patch.set_facecolor("#1e1e2e")
    ax.set_facecolor("#1e1e2e")

    # DB 라인 (빨강)
    if db_p95:
        xs = sorted(db_p95.keys())
        ys = [db_p95[x] for x in xs]
        ax.plot(xs, ys, color="#ff6b6b", linewidth=2.5,
                marker="o", markersize=8, label="DB 직접 방식 (구버전)", zorder=3)

    # Redis 라인 (초록)
    if redis_p95:
        xs = sorted(redis_p95.keys())
        ys = [redis_p95[x] for x in xs]
        ax.plot(xs, ys, color="#51cf66", linewidth=2.5,
                marker="o", markersize=8, label="Redis write-behind (신버전)", zorder=3)

    # 1000ms 기준선
    ax.axhline(y=1000, color="#ffd43b", linewidth=1.2,
               linestyle="--", alpha=0.7, label="1초 임계치")

    # 스타일
    ax.set_xlabel("RPS (Requests Per Second)", fontsize=13, color="white", labelpad=10)
    ax.set_ylabel("P95 응답시간 (ms)", fontsize=13, color="white", labelpad=10)
    ax.set_title("DB vs Redis 메시지 전송 응답 시간 비교",
                 fontsize=16, fontweight="bold", color="white", pad=20)

    ax.tick_params(colors="white", labelsize=11)
    for spine in ax.spines.values():
        spine.set_edgecolor("#444")

    ax.set_xticks(RPS_LEVELS)
    ax.grid(True, color="#333", linestyle="-", alpha=0.5, zorder=0)
    ax.legend(fontsize=11, facecolor="#2d2d3e", edgecolor="#555",
              labelcolor="white", loc="upper left")

    # 데이터 포인트 값 표시
    for rps, val in db_p95.items():
        ax.annotate(f"{int(val)}ms", (rps, val),
                    textcoords="offset points", xytext=(0, 10),
                    ha="center", fontsize=9, color="#ff6b6b")
    for rps, val in redis_p95.items():
        ax.annotate(f"{int(val)}ms", (rps, val),
                    textcoords="offset points", xytext=(0, -18),
                    ha="center", fontsize=9, color="#51cf66")

    plt.tight_layout()
    out_path = os.path.join(os.path.dirname(__file__), "chat_bench_comparison.png")
    plt.savefig(out_path, dpi=150, bbox_inches="tight",
                facecolor=fig.get_facecolor())
    print(f"\n그래프 저장: {out_path}")
    plt.show()


if __name__ == "__main__":
    main()
