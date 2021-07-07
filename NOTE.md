# Use Zymkey to perform TLS client auth

Follow the steps below to create the required CA and client cert:
https://community.zymbit.com/t/aws-iot-tls-client-certificate-authentication-using-zymkey-4i/214

Then use it in an https request:

```js
const https = require('https');
const crypto = require('crypto');

crypto.setEngine('/opt/libzymkeyssl/libzymkey_ssl.so');
const agent = new https.Agent({
	cert: fs.readFileSync('zymkey.crt'),
	privateKeyIdentifier: 'dummy',
	privateKeyEngine: '/opt/libzymkeyssl/libzymkey_ssl.so',
	rejectUnauthorized: false,
});

const req = https.request({agent: agent, ...});
```