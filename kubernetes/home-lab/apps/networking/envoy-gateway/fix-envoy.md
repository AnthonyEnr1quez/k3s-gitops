```log
[2024-11-25 03:43:08.564][1][warning][config] [./source/extensions/config_subscription/grpc/grpc_stream.h:226] DeltaAggregatedResources gRPC config stream to xds_cluster closed since 30s ago: 14, upstream connect error or disconnect/reset before headers. reset reason: remote connection failure, transport failure reason: TLS_error:|268435581:SSL routines:OPENSSL_internal:CERTIFICATE_VERIFY_FAILED:TLS_error_end
```

If you ever see the above

delete these secrets in the networking ns

```sh
kubectl delete secret envoy envoy-gateway envoy-oidc-hmac envoy-rate-limit 
```

and then they will regen

```sh
envoy-gateway-gateway-helm-certgen-xf57p
```