@echo off
set GITHUB_USERNAME=lailaaquino
set GITHUB_EMAIL=lailaaquino8@gmail.com 

set SERVICE_NAME=payment
set RELEASE_VERSION=v1.2.3

go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
set PATH=%PATH%;%GOPATH%\bin

echo Generating Go source code
mkdir golang 2>nul

protoc --go_out=./golang ^
  --go_opt=paths=source_relative ^
  --go-grpc_out=./golang ^
  --go-grpc_opt=paths=source_relative ^
  ./%SERVICE_NAME%/*.proto

echo Generated Go source code files
dir .\golang\%SERVICE_NAME%

cd golang\%SERVICE_NAME%

if not exist go.mod go mod init github.com/%GITHUB_USERNAME%/microservices-proto/golang/%SERVICE_NAME%
go mod tidy

REM cd ../../
REM git config --global user.email %GITHUB_EMAIL%
REM git config --global user.name %GITHUB_USERNAME%
REM git add . && git commit -am "proto update" || ver >nul
REM git push -u origin HEAD
REM git tag -d ch03/listing_3.2/golang/%SERVICE_NAME%/%RELEASE_VERSION%
REM git push --delete origin ch03/listing_3.2/golang/%SERVICE_NAME%/%RELEASE_VERSION%
REM git tag -fa ch03/listing_3.2/golang/%SERVICE_NAME%/%RELEASE_VERSION% ^
REM   -m "ch03/listing_3.2/golang/%SERVICE_NAME%/%RELEASE_VERSION%"
REM git push origin refs/tags/ch03/listing_3.2/golang/%SERVICE_NAME%/%RELEASE_VERSION%