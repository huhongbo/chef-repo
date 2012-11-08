# mcollective config

# stomp config
default["mcollective"]["stomp"]["host"] = "pc-mon02"
default["mcollective"]["stomp"]["port"] = "61613"
default["mcollective"]["stomp"]["user"] = "mcollective"
default["mcollective"]["stomp"]["password"] = "admin"

# mcollective plugins path

default["mcollective"]["libdir"] = "/etc/mcollective/mcollective-plugins"

# mcollective security
default["mcollective"]["psk"] = "abcdefghj"

default['mcollective']['fact_whitelist'] = [
                                            'fqdn',
                                            'hostname',
                                            'ipaddress',
                                            'macaddress',
                                            'os',
                                            'os_version',
                                            'platform',
                                            'platform_version',
                                            'ohai_time',
                                            'uptime',
                                            'uptime_seconds'
                                           ]