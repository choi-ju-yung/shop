@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: ============================================================
:: JMeter 설치 경로 (본인 경로로 수정)
:: ============================================================
set JMETER_BIN=C:\apache-jmeter-5.6.3\bin\jmeter.bat

:: 프로젝트 루트 (bench\ 상위 폴더)
set PROJECT_ROOT=%~dp0..
set JMX=%PROJECT_ROOT%\jmeter\chat_bench_test.jmx
set RESULTS=%PROJECT_ROOT%\jmeter\results

mkdir "%RESULTS%" 2>nul

echo.
echo ============================================================
echo   채팅 DB vs Redis 성능 벤치마크 자동 실행
echo   결과 저장: %RESULTS%
echo ============================================================
echo.

:: RPS별 테스트 실행 (100 / 200 / 300 / 500 / 800 / 1000)
for %%R in (100 200 300 500 800 1000) do (
    set /a TPM=%%R*60

    echo [%%R RPS  /  !TPM! per-min] 테스트 시작...

    :: JMeter를 jmeter\ 폴더에서 실행 → results\ 상대경로가 jmeter\results\ 로 해석됨
    pushd "%PROJECT_ROOT%\jmeter"
    call "%JMETER_BIN%" -n ^
        -t "%JMX%" ^
        -JTARGET_RPS=%%R ^
        -JTHROUGHPUT_PER_MIN=!TPM! ^
        -JDURATION=60 ^
        -Jjmeter.save.saveservice.output_format=csv
    popd

    echo [%%R RPS] 완료 → db_%%Rrps.csv / redis_%%Rrps.csv 저장됨
    echo.
)

echo ============================================================
echo   모든 테스트 완료. 그래프 생성 중...
echo ============================================================

cd /d "%~dp0"
python generate_graph.py

echo.
echo 그래프 생성 완료: bench\chat_bench_comparison.png
pause
