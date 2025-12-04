@echo off
echo Monitoring szolgaltatasok inditasa...
echo.
echo Prometheus: http://localhost:4300
echo Grafana:    http://localhost:4400
echo.
echo.

start /b minikube kubectl -- port-forward svc/prometheus-service 4300:9090 > nul 2>&1

start /b minikube kubectl -- port-forward svc/grafana-service 4400:3000 > nul 2>&1

pause