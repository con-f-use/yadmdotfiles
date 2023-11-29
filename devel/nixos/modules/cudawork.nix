{ config, lib, pkgs, ... }:
let
  interceptionCert = ''
    -----BEGIN CERTIFICATE-----
    MIIEEjCCAvqgAwIBAgIBATANBgkqhkiG9w0BAQsFADCBwTELMAkGA1UEBhMCQVQx
    GzAZBgNVBAoMEkJhcnJhY3VkYSBOZXR3b3JrczElMCMGA1UEAwwcRGV2ZWxvcG1l
    bnQgU1NMIEludGVyY2VwdGlvbjEOMAwGA1UECAwFVGlyb2wxEjAQBgNVBAcMCUlu
    bnNicnVjazEQMA4GA1UECwwHSU5OLURFVjE4MDYGCSqGSIb3DQEJARYpRU1FQUVu
    Z2luZWVyaW5nQXVzdHJpYV9UZWFtQGJhcnJhY3VkYS5jb20wHhcNNzAwMTAxMDAw
    MDAwWhcNMzgwMTE5MDMxNDA3WjCBwTELMAkGA1UEBhMCQVQxGzAZBgNVBAoMEkJh
    cnJhY3VkYSBOZXR3b3JrczElMCMGA1UEAwwcRGV2ZWxvcG1lbnQgU1NMIEludGVy
    Y2VwdGlvbjEOMAwGA1UECAwFVGlyb2wxEjAQBgNVBAcMCUlubnNicnVjazEQMA4G
    A1UECwwHSU5OLURFVjE4MDYGCSqGSIb3DQEJARYpRU1FQUVuZ2luZWVyaW5nQXVz
    dHJpYV9UZWFtQGJhcnJhY3VkYS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
    ggEKAoIBAQC+6MLB12q9QXUhsaBtAdHKqKOraFRdtvVtHB2fMssH7rGKLSXtZgVC
    FYs7JUeW5pOHNGSg/L/wAVWY7gLyGiqZUcFW5GAb1YeMy5U6rsn6lYscs/rsefiP
    MGPZ6TD6vA9HC0u20WVEpTZf7Qxho+ljp1z7HKmEZZV8vcRVpC7Y1L/Y2lB6AnH6
    el5oxj8fiGROXcwzzHCnVCnXX0j3bX7yI6GdbbITKp5EwzmjI8Jw42AHUUHZoUQQ
    WcFIOgX1M71MW1iEm5S/mcpMcM8XwXzEKrnyRn5eSMW6b1bycl/sSqVsojB2QnCB
    rKlLYiO7y44eSeXkAs2g+ctCsGZZAbLFAgMBAAGjEzARMA8GA1UdEwEB/wQFMAMB
    Af8wDQYJKoZIhvcNAQELBQADggEBACf5UPiKjEDxRg1yAptx1/cfKimiw7hc0aYI
    aFeAPwygkQ248qjZiCBarxBJtXtGT7P68YHgbRpBCI61O6Ycl3Qj08QbLqyMwQhF
    JeeBpTtdHcShJzS0yvqRkV4hMR1Y7V7I0Crob3SZpp8LaAwY2Z+94EWpOoi5/Qvz
    30+ALqTff5hTvAMNYyb2SMSqqdsBoHFkeV5bH3GDPAoqPcv9ZcbXnyXBSGYY3oPL
    ej7pIeyAJiyOtVkSED+fyz/gdq+pCQLXAIMeTjOpgT+KJ2Qm6Dsi74zvV3UfIi9F
    zI71uyq/VV3IdKn2n3I3S7gao++C8SNCRkuTINtlqDytPLp4N3o=
    -----END CERTIFICATE-----
  '';
  qacaCert = ''
    -----BEGIN CERTIFICATE-----
    MIIEVTCCAz2gAwIBAgIBATANBgkqhkiG9w0BAQsFADCBszELMAkGA1UEBhMCQVQx
    DjAMBgNVBAgTBVR5cm9sMRIwEAYDVQQHEwlJbm5zYnJ1Y2sxGzAZBgNVBAoTEkJh
    cnJhY3VkYSBOZXR3b3JrczEmMCQGA1UECxMdTkcgRmlyZXdhbGwgUXVhbGl0eSBB
    c3N1cmFuY2UxEDAOBgNVBAMTB1FBIFJvb3QxKTAnBgkqhkiG9w0BCQEWGm1ncm9z
    c2hhdXNlckBiYXJyYWN1ZGEuY29tMB4XDTE1MDUxMzE2MTkwMFoXDTI1MDUxMzE2
    MTkwMFowgbMxCzAJBgNVBAYTAkFUMQ4wDAYDVQQIEwVUeXJvbDESMBAGA1UEBxMJ
    SW5uc2JydWNrMRswGQYDVQQKExJCYXJyYWN1ZGEgTmV0d29ya3MxJjAkBgNVBAsT
    HU5HIEZpcmV3YWxsIFF1YWxpdHkgQXNzdXJhbmNlMRAwDgYDVQQDEwdRQSBSb290
    MSkwJwYJKoZIhvcNAQkBFhptZ3Jvc3NoYXVzZXJAYmFycmFjdWRhLmNvbTCCASIw
    DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMi18E3jeRafibqkWEvKWgX5nsmw
    GQfJ1o77UDDRQD9YOjA3WhD1wUf/t5gnZ9ICS2dlPCwz6/lRkv+AYJBBfB0+ggf5
    qCb90lHCTLlS5QQ8RwdAI/4hY0cs0LeO1Uc9dz9qxM0Q5F2RUclyq9lUr7G05Y8j
    jL3IQGDFn51Y80yjH/QXbS18SXnqX6UilwhnR+z5wqPfyEL9xgdpGfD1rpqst4PO
    joCAFKrfPEJKwRybxntzLZGtWwiXTw0bjKzlB0ybISCQlO7LYMjwUKGQKpnL5RIV
    P31ydyzOL/ruAwZoi6G0kmd9CV0HEj0VJxmnUKdQy5TQ8w8PN33lDU71+V0CAwEA
    AaNyMHAwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUQDE237rS9zaiSz+A2nap
    hU5OTuQwCwYDVR0PBAQDAgEGMBEGCWCGSAGG+EIBAQQEAwIABzAeBglghkgBhvhC
    AQ0EERYPeGNhIGNlcnRpZmljYXRlMA0GCSqGSIb3DQEBCwUAA4IBAQBCT3fTaXZL
    ATQtObOd3vcXCpyWQpa0DUP0JU3kpfw1QOGhHcvZKuuhkOUdb3zP2VHANez3bL3Z
    crIjAcxKa2PMsx9CyczTGXMfMbyearQF1HqRl747+tqcxUBwyCAjFsVrKvoPZjgF
    /gUpm/SmzyhgL6zvCZZHc1rGuxOm8byFc2MGLQNBtMPOSDSwExbVJSFlRn0ZHTCn
    +14Xl9z/Ia2ZQEPlXzAHdL9IRThiOJMnFxs1u9XbajQCVPL4MAIDpzyDsnu8uwEP
    60GvkjQcooz1/1hL/PQzGdeigNRClagpLcGY+3O+4x4vkJjWuZcuc5+g5gycWgal
    ufdPjWGc35FL
    -----END CERTIFICATE-----
  '';
  dockregCert = ''
    -----BEGIN CERTIFICATE-----
    MIIErDCCA5SgAwIBAgIIFZ02OZrpakswDQYJKoZIhvcNAQELBQAwgbMxCzAJBgNV
    BAYTAkFUMQ4wDAYDVQQIEwVUeXJvbDESMBAGA1UEBxMJSW5uc2JydWNrMRswGQYD
    VQQKExJCYXJyYWN1ZGEgTmV0d29ya3MxJjAkBgNVBAsTHU5HIEZpcmV3YWxsIFF1
    YWxpdHkgQXNzdXJhbmNlMRAwDgYDVQQDEwdRQSBSb290MSkwJwYJKoZIhvcNAQkB
    FhptZ3Jvc3NoYXVzZXJAYmFycmFjdWRhLmNvbTAeFw0yMDA2MDMxMjUxMDBaFw0y
    NTA1MTMxNjE5MDBaMIGmMQswCQYDVQQGEwJBVDEOMAwGA1UECBMFVGlyb2wxEjAQ
    BgNVBAcTCUlubnNicnVjazEbMBkGA1UEChMSQmFycmFjdWRhIE5ldHdvcmtzMQsw
    CQYDVQQLEwJRQTEhMB8GA1UEAxMYQXV0b3Rlc3QgRG9ja2VyIFJlZ2lzdHJ5MSYw
    JAYJKoZIhvcNAQkBFhdOR1FBX1RlYW1AYmFycmFjdWRhLmNvbTCCASIwDQYJKoZI
    hvcNAQEBBQADggEPADCCAQoCggEBAL7rpgewhrhBLssPftYUGdcbtfAbUUcZnp5k
    cWEmhc/BEfo3unWdE+WP3Ey+KzpXVJIDyiwqfYpYyzx8ebRlYOPYy/1XRDArU8os
    3CspCAAlT3Hdwfk7z9yhkwtdQq8qDDTDogMONX+G9IQoW+Ydx21HvGNe7BsYf4pa
    BD7KUJUrO4PY8Rfd3Nl4SU2NWzrHdEEQIoWRFuB9z8ChSHF6GHPAkaA6zAqJuiSH
    y9YarZLpIRv2pWVVuIl1M9JanklFFIOKNxWxIteiEsrzAVBgI8hAiO4kdj4WMuOk
    PT1jBd3/pWbbvZheDq7KCHrLVMbwxtR0TTfc0FS4uQfWiYWRyZMCAwEAAaOBzjCB
    yzAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBS2/RBdqNFWyogrGJ/nl+2XsM/a6zAL
    BgNVHQ8EBAMCBeAwEwYDVR0lBAwwCgYIKwYBBQUHAwEwRQYDVR0RBD4wPII0YXV0
    b3Rlc3QtZG9ja2VyLXJlZ2lzdHJ5LnFhLm5nZGV2LmV1LmFkLmN1ZGEtaW5jLmNv
    bYcEChFByTARBglghkgBhvhCAQEEBAMCBkAwIAYJYIZIAYb4QgENBBMWEW9iZXkg
    eW91ciBtYXN0ZXIhMA0GCSqGSIb3DQEBCwUAA4IBAQAlu0P86MHFmJuxqbtN9UO4
    1BRGUAaKqR79dqSjBurMnxjdV+3fq3GLlHvZfCi5ykkhnwhgpYoVGpUcwb3tY/CC
    idluqSsVpSjFj9tljm7T81mVjG4JxUkzmT8GCfYLxHVvl8vFFYOe5mgVjQhupuRu
    gYrVv2eccgAmfPLbQ0R+3QxQ4MBN0BiYiHj/z01ieRcwFQoVI3G2cTMdE7s0I/KA
    U8UZNBeQ48VzUjAU0uvrruiv7t7yftfZMQJIwh658sfweyQ/aCSoj0EOGANHW7LP
    nbDw7DyHV3cBjIClpEYRUV+BR47hWWO8W5f4fQ0pmFCGU4EobPZI+IUiw3TWf5vV
    -----END CERTIFICATE-----
  '';
  dockerregCert2 = ''
    -----BEGIN CERTIFICATE-----
    MIIFGzCCBAOgAwIBAgIIaVSMGhMix0AwDQYJKoZIhvcNAQELBQAwgbcxCzAJBgNV
    BAYTAkFUMQ4wDAYDVQQIEwVUaXJvbDESMBAGA1UEBxMJSW5uc2JydWNrMRswGQYD
    VQQKExJCYXJyYWN1ZGEgTmV0d29ya3MxGDAWBgNVBAsTD05HRi1EZXZlbG9wbWVu
    dDEoMCYGA1UEAxMfaWRlZml4Lm5nZGV2LmV1LmFkLmN1ZGEtaW5jLmNvbTEjMCEG
    CSqGSIb3DQEJARYUbWh1dGVyQGJhcnJhY3VkYS5jb20wHhcNMjExMTE1MDgwOTAw
    WhcNMjMxMTE1MDgwOTAwWjCBwDELMAkGA1UEBhMCQVQxDjAMBgNVBAgTBVRpcm9s
    MRIwEAYDVQQHEwlJbm5zYnJ1Y2sxGzAZBgNVBAoTEkJhcnJhY3VkYSBOZXR3b3Jr
    czEYMBYGA1UECxMPTkdGLURldmVsb3BtZW50MTEwLwYDVQQDEyhkb2NrZXItcmVn
    aXN0cnkubmdkZXYuZXUuYWQuY3VkYS1pbmMuY29tMSMwIQYJKoZIhvcNAQkBFhRt
    aHV0ZXJAYmFycmFjdWRhLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
    ggEBAMVl/ZPsNSfg3/Irav6Ot5qM3QpXBKRG9rbSmw0dnypiCtb4vpOjY3cr1vo3
    w4fTfBQYEl3M2WhafuH8GZ5O3ge+pxJQsdnRs6UN//AiXF1EJFs1TEHFlD5QlFg2
    qcVktc0kk52T5nJa0l9UC0ESBDgTVaX86dz4ZsYWpeXDayLAnCLeRIPCaItN1nzX
    duqoMeKkD+XV7GKjbfOmPt1ZeP4aoWXnjJy9tty085EOGK1YLSz4rcY87pGJ3F4H
    sC+Kkre3Kz6TkB9McgwDOVuUBMz2WrxSwmuOMkFgiriV9RioxBpn/8wMv4z1O+Xi
    jDYH0H8kLV3h+3BP4IjWjYlEuf8CAwEAAaOCAR4wggEaMAwGA1UdEwEB/wQCMAAw
    HQYDVR0OBBYEFNUVnuZo9A9Xh0ttnIr+S6e44J44MA4GA1UdDwEB/wQEAwIF4DAW
    BgNVHSUBAf8EDDAKBggrBgEFBQcDATBvBgNVHREEaDBmhjRodHRwczovL2RvY2tl
    ci1yZWdpc3RyeS5uZGV2LmV1LmFkLmN1ZGEtaW5jLmNvbTo1MDAwhwQKG9Jbgihk
    b2NrZXItcmVnaXN0cnkubmdkZXYuZXUuYWQuY3VkYS1pbmMuY29tMB8GA1UdEgQY
    MBaBFG1odXRlckBiYXJyYWN1ZGEuY29tMBEGCWCGSAGG+EIBAQQEAwIGQDAeBglg
    hkgBhvhCAQ0EERYPeGNhIGNlcnRpZmljYXRlMA0GCSqGSIb3DQEBCwUAA4IBAQC2
    a5be9Jlu6IifGgncqPeDsrDHIv9HfZrTZ79LU6O3XgVSKsXbN9kvZcUNKj4PY/Jt
    gF6Q1x5d9Pz6XWq/d/VbYVX9+R27gfES7MWxDArUvvG2ADgmu847J22wfe6LjLD6
    k7wt406UCOj/3oKkQyuClxdwzb/itp8CUfAy2G5GB3fKIClCWc6GJKCZWbLzZerk
    B7K4hQg/RktFRN5UYLie/7RiqFzcm6BIWeJXEn79qyNaamJ/nDsIo5ouTv78eiNi
    r3YIO2R62esQQRKpribY8n1U/YK3MHLgBTls6mOUTvkHluZXkv05t1QYDb67DuZV
    U36rHxKauoNJga9f9Nd3
    -----END CERTIFICATE-----
  '';
  folsomCert = ''
    -----BEGIN CERTIFICATE-----
    MIIE0TCCA7mgAwIBAgIId92CKHsdEz8wDQYJKoZIhvcNAQELBQAwgbcxCzAJBgNV
    BAYTAkFUMQ4wDAYDVQQIEwVUaXJvbDESMBAGA1UEBxMJSW5uc2JydWNrMRswGQYD
    VQQKExJCYXJyYWN1ZGEgTmV0d29ya3MxGDAWBgNVBAsTD05HRi1EZXZlbG9wbWVu
    dDEoMCYGA1UEAxMfaWRlZml4Lm5nZGV2LmV1LmFkLmN1ZGEtaW5jLmNvbTEjMCEG
    CSqGSIb3DQEJARYUbWh1dGVyQGJhcnJhY3VkYS5jb20wHhcNMjExMTE1MTIyNzAw
    WhcNMjMxMTE1MTIyNzAwWjCBtzELMAkGA1UEBhMCQVQxDjAMBgNVBAgTBVRpcm9s
    MRIwEAYDVQQHEwlJbm5zYnJ1Y2sxGzAZBgNVBAoTEkJhcnJhY3VkYSBOZXR3b3Jr
    czEYMBYGA1UECxMPTkdGLURldmVsb3BtZW50MSgwJgYDVQQDEx9mb2xzb20ubmdk
    ZXYuZXUuYWQuY3VkYS1pbmMuY29tMSMwIQYJKoZIhvcNAQkBFhRtaHV0ZXJAYmFy
    cmFjdWRhLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKTTJ1v0
    wKM9DkzIoE+vsa236YcEYkRxYg9Zam+WXhtDNyYmkNzoirW9TbiHypKfXmIOFx+z
    +RGCJ8SmCF5M+xsA8J2krNtisK8cxg1hvEjTIYyjGybAi8wg0T+FyvTuxE59vZOz
    08yTbduth9cjCBY+sofYuxvlU16WpcVN3ZZhr3b7upJH3njwEGLMiRDhgo3nhj+Z
    2gUqFXbSY17pxHueA8wDX4zktmQFhC5KdNebtFN4aLw0zuPdbO2ijtLTEkFNfcwj
    qzp3v61waSHi1Do70zKenBO6V8gIBLEmJkdmjKTzc6ybQWZPWqPlX4wOv45H6a7X
    GRN1cEk1O0Kf1dMCAwEAAaOB3jCB2zAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBSn
    lwxQ7XlKuUdywIh1dZyOZHxRtTAOBgNVHQ8BAf8EBAMCBeAwFgYDVR0lAQH/BAww
    CgYIKwYBBQUHAwEwMAYDVR0RBCkwJ4IfZm9sc29tLm5nZGV2LmV1LmFkLmN1ZGEt
    aW5jLmNvbYcEChHSkTAfBgNVHRIEGDAWgRRtaHV0ZXJAYmFycmFjdWRhLmNvbTAR
    BglghkgBhvhCAQEEBAMCBkAwHgYJYIZIAYb4QgENBBEWD3hjYSBjZXJ0aWZpY2F0
    ZTANBgkqhkiG9w0BAQsFAAOCAQEAPhnjh4rCfSrnpTFufxmsa2fnaXMGFThHfSIF
    nAMbSqT23yh0T8v32oHdteTsa4DiiSWviMNZlFFTZJGJ3qFgYBsQ8AEw8m5xtUKp
    VP6fq77eRfmHnvCD0hBOOmvnBCYfpUnzUd1ZQ0zT30VCjZS9toNI1fWloRh+Wj2z
    IDstU1FBTpYfgr3AvNABvjeRtHPg5zY52iAI9hRhXvyM5NyxTPtcNXa8W4MDEG4d
    Ne2w0PI9S+gpThRJtPOC734X3aTYou1emj7qDJyqU6TQ2b3blicbqied8oBTsz/O
    z+dpo63MECsQMnrhsuU7apE0Jn3mqqCLQA4nPgxbkn1GqQJTVQ==
    -----END CERTIFICATE-----
  '';
  idefixCert = ''
    -----BEGIN CERTIFICATE-----
    MIIFFjCCA/6gAwIBAgIIHctWPinSWsAwDQYJKoZIhvcNAQELBQAwgbcxCzAJBgNV
    BAYTAkFUMQ4wDAYDVQQIEwVUaXJvbDESMBAGA1UEBxMJSW5uc2JydWNrMRswGQYD
    VQQKExJCYXJyYWN1ZGEgTmV0d29ya3MxGDAWBgNVBAsTD05HRi1EZXZlbG9wbWVu
    dDEoMCYGA1UEAxMfaWRlZml4Lm5nZGV2LmV1LmFkLmN1ZGEtaW5jLmNvbTEjMCEG
    CSqGSIb3DQEJARYUbWh1dGVyQGJhcnJhY3VkYS5jb20wHhcNMjMwMTI2MTQzMDAw
    WhcNMjUwMTI2MTQzMDAwWjCBwDELMAkGA1UEBhMCQVQxDjAMBgNVBAgTBVRpcm9s
    MRIwEAYDVQQHEwlJbm5zYnJ1Y2sxGzAZBgNVBAoTEkJhcnJhY3VkYSBOZXR3b3Jr
    czEYMBYGA1UECxMPTkdGLURldmVsb3BtZW50MTEwLwYDVQQDEyhqZW5raW5zLWp1
    cGl0ZXIubmdkZXYuZXUuYWQuY3VkYS1pbmMuY29tMSMwIQYJKoZIhvcNAQkBFhRt
    aHV0ZXJAYmFycmFjdWRhLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
    ggEBALWm2I/nmcKiakvVaUqqf3JMnAiAPVhF0Hu2OqVW121MHjojQKoBaLyyN0Nn
    uNVQakwk3er27elRJrvEK1qifuqjkzgyl2WZkd55QMvgKDMx2Yo3yaBZ5Ze0HDug
    AFsErzaxGGabq8vh9FRyG5ACsKYGiy4xO9tlTkB1nK+I3W7bKY1zMTiHwY+LjF1K
    PsThjPUYG+VRQ53Y5xChFsHQX4/BNuwIbo3FONBmc+AT61P4daX7DiSzQBbK/MEB
    GV4gQSGLETyPuMNO8K7HmD1iimvGaOOGb8rOJZ9UcTL2Wuu3CjNRY+kld8Y/Ty6k
    CwNrI4G3af9M4uzFpojWVfLV6O8CAwEAAaOCARkwggEVMAwGA1UdEwEB/wQCMAAw
    HQYDVR0OBBYEFILGOF77UqyHWaqqpAapzowsu5miMA4GA1UdDwEB/wQEAwIF4DAW
    BgNVHSUBAf8EDDAKBggrBgEFBQcDATBqBgNVHREEYzBhhi9odHRwczovL2plbmtp
    bnMtanVwaXRlci5uZGV2LmV1LmFkLmN1ZGEtaW5jLmNvbYcEChHSTIIoamVua2lu
    cy1qdXBpdGVyLm5nZGV2LmV1LmFkLmN1ZGEtaW5jLmNvbTAfBgNVHRIEGDAWgRRt
    aHV0ZXJAYmFycmFjdWRhLmNvbTARBglghkgBhvhCAQEEBAMCBkAwHgYJYIZIAYb4
    QgENBBEWD3hjYSBjZXJ0aWZpY2F0ZTANBgkqhkiG9w0BAQsFAAOCAQEAt6YApohg
    cjIrxkuOjvWQ2lZD0my2cfVDYZCY2nqdAqifZnQ2WY8hNCMixsyDYDH070m144II
    5sdyfgpqim5J3tVnbe/sE4nosoJsx6tc+jhFO/02PSNPWtoyJmOtL193nN7EazYd
    NItD4aYpSj8fmlHoFsb64ZGJhOvdNVOCJPghXDNqJGIfPcteILdoNkdZjuspzDd9
    ctH05htsH0HBKa052jmvYuVE6MCq9vd+rxHQV39KcZ2pxxf92y1wjMxegBPYI8fo
    cxOJ/ADRWbtlB+NeKptLsteXcSF8SNYifZvBIkV5byN+mj1NXfJBVBi5xsoOiMcu
    ambeaC62HBlibg==
    -----END CERTIFICATE-----
  '';

  systemCerts = [ interceptionCert qacaCert folsomCert idefixCert dockregCert dockerregCert2 ];
  nixbuilderkeypath = "nix/nixbuilder";

in
{
  options.roles.cudawork = with lib; {
    enable = mkEnableOption "Enable cuda-specific settings for my workstation";
    novpn = mkOption { description = "Do not install barracudavpn"; type = types.bool; default = false; };
    interception = mkOption { description = "Are we beind SSL-Interception? If true add Cert."; type = types.bool; default = false; };
    use_builders = mkOption { description = "Use nix builder client specific configuration"; type = types.bool; default = false; };
  };

  config = lib.mkIf (config.roles.cudawork.enable) (lib.mkMerge [
    {
      virtualisation.docker = {
        enable = true;
        enableOnBoot = true;
        autoPrune.enable = true;
        daemon.settings = {
          insecure-registries = [
            "10.17.65.200:5000"
            "10.17.65.201:5000"
            "autotest-docker-registry.qa.ngdev.eu.ad.cuda-inc.com:5000"
            "docker-registry.qa.ngdev.eu.ad.cuda-inc.com:5000"
            "jenkins-jupiter.ngdev.eu.ad.cuda-inc.com"
          ];
          dns = [ "10.17.6.120" "1.1.1.1" ];
        };
      };

      networking.hosts = {
        "10.17.6.11" = [ "qda-vault.qa.ngdev.eu.ad.cuda-inc.com" "vault.qa" ];
        "10.17.50.250" = [ "portal.qa.ngdev.eu.ad.cuda-inc.com" "portal.qa" ];
        "10.17.50.102" = [ "portal-staging.qa.ngdev.eu.ad.cuda-inc.com" "portal-staging.qa" ];
        "10.17.50.246" = [ "jenkins-cgf.qa.ngdev.eu.ad.cuda-inc.com" "jenkins2.qa" ];
        "10.17.210.76" = [ "jenkins-jupiter.ngdev.eu.ad.cuda-inc.com" ];
        "10.17.50.238" = [ "jenkins-cloud.qa.ngdev.eu.ad.cuda-inc.com" ];
        "10.17.6.61" = [ "nixbld01.qa.ngdev.eu.ad.cuda-inc.com" "nixbld01.qa" ];
        "10.17.6.62" = [ "nixbld02.qa.ngdev.eu.ad.cuda-inc.com" "nixbld02.qa" ];
        "10.17.6.63" = [ "nixbld03.qa.ngdev.eu.ad.cuda-inc.com" "nixbld03.qa" ];
        "10.17.6.120" = [ "dns.qa" ];
        "10.17.65.200" = [ "docker-registry.qa.ngdev.eu.ad.cuda-inc.com" "docker.qa" ];
        "10.17.65.201" = [ "autotest-docker-registry.qa.ngdev.eu.ad.cuda-inc.com" "autodocker.qa" ];
        "10.17.65.203" = [ "pypi.qa.ngdev.eu.ad.cuda-inc.com" "pypi.qa" ];
        "10.17.210.145" = [ "folsom.ngdev.eu.ad.cuda-inc.com" "folsom.qa" ];
        "10.14.0.22" = [ "docker-c7.3sp.co.uk" ];
        "10.17.33.51" = [ "idefix.ngdev.eu.ad.cuda-inc.com" ];
        "10.17.33.215" = [ "troubadix.ngdev.eu.ad.cuda-inc.com" ];
        "10.17.210.200" = [ "order.ngdev.eu.ad.cuda-inc.com" ];
        "10.27.210.91" = [ "docker-registry.ngdev.eu.ad.cuda-inc.com" ];
      };

      programs.ssh = {
        # knownHostsFiles = [ ./known_hosts ];
        extraConfig = ''
          Host stash st
            HostName stash.cudaops.com
            Port 7999
            IdentitiesOnly yes
          Host folsom fol fl
            HostName folsom.ngdev.eu.ad.cuda-inc.com
            Port 7999
            IdentitiesOnly yes
          Host friederike rike
            HostName friederike.ngdev.eu.ad.cuda-inc.com
          Host order
            HostName order.ngdev.eu.ad.cuda-inc.com
        '';
      };

      security.pki.certificates = systemCerts;

      environment.etc."docker/cert.d/10.17.65.201:5000/certificate.crt" = {
        enable = true;
        user = "docker";
        group = "docker";
        text = if config.roles.cudawork.interception then interceptionCert else dockregCert;
      };
      environment.etc."docker/cert.d/10.17.65.200:5000/certificate.crt" = {
        enable = true;
        user = "docker";
        group = "docker";
        text = if config.roles.cudawork.interception then interceptionCert else dockregCert;
      };
      environment.etc."docker/cert.d/docker-registry.qa.ngdev.eu.ad.cuda-inc.com:5000/certificate.crt" = {
        enable = true;
        user = "docker";
        group = "docker";
        text = dockerregCert2;
      };
      environment.etc."docker/cert.d/jenkins-jupiter.ngdev.eu.ad.cuda-inc.com:5000/certificate.crt" = {
        enable = true;
        user = "docker";
        group = "docker";
        text = idefixCert;
      };

      environment.systemPackages = with pkgs; [
        poetry
        pipenv
        jq
        docker-compose
        postgresql
        groovy #devpi-client
        vault
        qda-repos
      ] ++ lib.optional (config.roles.cudawork.novpn == false) barracudavpn;
    }

    (lib.mkIf config.services.xserver.enable {
      environment.systemPackages = with pkgs; [
        zoom-us
        slack
        robo3t
      ];

      #nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg)
      #  [ "slack" "zoom-us" ]
      #;
      allowUnfreePackages = [ "slack" "zoom-us" "zoom" ];
    })

    (lib.mkIf config.roles.cudawork.use_builders {
      environment.etc = {
        "${nixbuilderkeypath}" = {
          source = pkgs.fetchurl {
            urls = [
              "ftp://qa:qa@10.17.6.4/nix/nixbuilder"
            ];
            hash = "sha256-YHklGvvnUlTHTNkyapTjHBiYRKieRRRejooqAHihWN0=";
          };
          enable = true;
          mode = "0400";
          uid = 0;
          gid = 0;
        };
      };

      nix.buildMachines = builtins.map
        (idx: {
          hostName = "nixbld0${toString idx}.qa.ngdev.eu.ad.cuda-inc.com";
          system = "x86_64-linux";
          maxJobs = 2;
          speedFactor = 1;
          supportedFeatures = [ "big-parallel" "kvm" "nixos-test" "benchmark" ];
          sshUser = "nixbuilder";
          sshKey = "/etc/${nixbuilderkeypath}";
        }) [ 1 2 3 ];

      nix.distributedBuilds = true;
      nix.extraOptions = ''builders-use-substitutes = true'';
    })

  ]);

}

