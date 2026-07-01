# Deploy com Docker - Projeto gRPC

Este projeto pode ser executado com Docker usando os containers:

- `mysql` (porta host `3307`)
- `payment` (porta host `3001`)
- `shipping` (porta host `3002`)
- `order` (porta host `3000`)

## Pre-requisitos

- Docker e Docker Compose instalados
- `grpcurl` instalado para os testes de gRPC

## 1) Pasta para executar

Abra um terminal na raiz deste repositorio (onde esta o arquivo `docker-compose.yml`).

## 2) Subir tudo

```powershell
docker compose up --build -d
```

## 3) Ver containers ativos

```powershell
docker compose ps
```

## 4) Ver logs

```powershell
docker compose logs -f
```

Logs de servicos especificos:

```powershell
docker compose logs -f order
docker compose logs -f payment
docker compose logs -f shipping
docker compose logs -f mysql
```

## 5) Testes gRPC (PowerShell)

### 5.1 Sucesso (item existente + pagamento aprovado)

```powershell
$body = '{"costumer_id":1,"order_items":[{"product_code":"a","unit_price":100,"quantity":3},{"product_code":"b","unit_price":50,"quantity":4}]}'
$body | grpcurl -plaintext -import-path "./microservices-proto/order" -proto order.proto -d '@' localhost:3000 Order/Create
```

Resultado esperado:

- Retorna `orderId`
- `order` chama `shipping` somente apos o pagamento com sucesso
- Prazo calculado no `shipping` com base no total de unidades

### 5.2 Erro de item inexistente

```powershell
$body = '{"costumer_id":1,"order_items":[{"product_code":"x","unit_price":10,"quantity":1}]}'
$body | grpcurl -plaintext -import-path "./microservices-proto/order" -proto order.proto -d '@' localhost:3000 Order/Create
```

Resultado esperado:

- Erro `NotFound` informando que o item nao existe no estoque

### 5.3 Erro de pagamento recusado

```powershell
$body = '{"costumer_id":1,"order_items":[{"product_code":"a","unit_price":600,"quantity":2}]}'
$body | grpcurl -plaintext -import-path "./microservices-proto/order" -proto order.proto -d '@' localhost:3000 Order/Create
```

Resultado esperado:

- Erro `InvalidArgument` para pagamento acima de 1000
- `shipping` nao deve ser chamado nesse caso

### 5.4 Teste direto do Shipping

```powershell
$body = '{"order_id":99,"items":[{"product_code":"a","quantity":10}]}'
$body | grpcurl -plaintext -import-path "./microservices-proto/shipping" -proto shipping.proto -d '@' localhost:3002 shipping.Shipping/Create
```

Resultado esperado:

- `deliveryDays = 3` (minimo 1 dia + 10/5)

## 6) Parar e remover containers

```powershell
docker compose down
```

Para remover tambem o volume do MySQL:

```powershell
docker compose down -v
```
