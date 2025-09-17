@echo off
REM ==================================================================
REM Generate CA, Server, Client certificates for mutual TLS (mTLS)
REM Works with Spring Boot (server) + Postman (client)
REM ==================================================================

set PASSWORD=password

echo.
echo [1] Generating CA keystore...
keytool -genkeypair -alias ca -keyalg RSA -keystore ca.jks -storepass %PASSWORD% -keypass %PASSWORD% -dname "CN=MyCA" -ext bc:c

echo.
echo [2] Exporting CA cert...
keytool -export -alias ca -keystore ca.jks -storepass %PASSWORD% -file ca.crt -rfc

echo.
echo [3] Generating Server keystore...
keytool -genkeypair -alias server -keyalg RSA -storetype PKCS12 -keystore server.p12 -storepass %PASSWORD% -keypass %PASSWORD% -dname "CN=localhost"

echo.
echo [4] Creating Server CSR...
keytool -certreq -alias server -keystore server.p12 -storepass %PASSWORD% -file server.csr

echo.
echo [5] Signing Server cert with CA...
keytool -gencert -alias ca -keystore ca.jks -storepass %PASSWORD% -infile server.csr -outfile server.crt -ext ku:c=dig,keyEncipherment -ext eku=serverAuth -rfc

echo.
echo [6] Importing CA and signed Server cert into server.p12...
keytool -importcert -alias ca -keystore server.p12 -storepass %PASSWORD% -file ca.crt -noprompt
keytool -importcert -alias server -keystore server.p12 -storepass %PASSWORD% -file server.crt -noprompt

echo.
echo [7] Creating Server truststore (trusts CA)...
keytool -importcert -alias ca -keystore truststore.jks -storepass %PASSWORD% -file ca.crt -noprompt

echo.
echo [8] Generating Client keystore...
keytool -genkeypair -alias client -keyalg RSA -storetype PKCS12 -keystore client.p12 -storepass %PASSWORD% -keypass %PASSWORD% -dname "CN=postman-client"

echo.
echo [9] Creating Client CSR...
keytool -certreq -alias client -keystore client.p12 -storepass %PASSWORD% -file client.csr

echo.
echo [10] Signing Client cert with CA (with clientAuth)...
keytool -gencert -alias ca -keystore ca.jks -storepass %PASSWORD% -infile client.csr -outfile client.crt -ext ku:c=dig,keyEncipherment -ext eku=clientAuth -rfc

echo.
echo [11] Importing CA and signed Client cert into client.p12...
keytool -importcert -alias ca -keystore client.p12 -storepass %PASSWORD% -file ca.crt -noprompt
keytool -importcert -alias client -keystore client.p12 -storepass %PASSWORD% -file client.crt -noprompt

echo.
echo ==================================================================
echo Certificates generated successfully!
echo - Server keystore: server.p12
echo - Server truststore: truststore.jks
echo - Client keystore (for Postman): client.p12
echo - CA cert: ca.crt
echo ==================================================================
pause