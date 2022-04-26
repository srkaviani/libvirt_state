# libvirt_state

This Project Used for send state Changes of instance to webhook urls.

## Requrements
1. Python3
2. Prometheus
3. Libvirt Exporter

## How to Use?

1. Download and run libvirt_state.sh to install.
2. Edit /opt/libvirt_state/app.py and change prometheus.local:9090 to address of your prometheus instance , https://webhook.test to your webhook receiver URL
3. RUN systemctl restart libvirt_state
