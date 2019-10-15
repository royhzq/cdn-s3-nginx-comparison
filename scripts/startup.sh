#!/bin/bash
yum update -y
amazon-linux-extras install python3 nginx1.12 -y
cat > local.conf << EOF
server {
    listen 80;
    server_name _;
    root /usr/share/nginx;
    location / {
    }
}
EOF
mv local.conf /etc/nginx/conf.d/local.conf
systemctl restart nginx
pip3 install requests 

# Get metadata for Availability zone
REGION=`curl --silent http://169.254.169.254/latest/meta-data/placement/availability-zone`
cat > get_payload.py << EOF 
import requests
import datetime
with open("/usr/share/nginx/html/" + "$REGION" + "-data.csv", "w") as f:

    n=1000
    origin = "$REGION" 
    source = {
        "CLOUDFRONT": "https://df3k2q0k3bu2n.cloudfront.net/static/payload",
        "S3": "https://amber-static.s3-ap-southeast-1.amazonaws.com/static/payload",
        "NGINX": "http://18.141.13.186/payload",
    }
    
    headers = "timestamp,url,server,resp_time,status_code,size,origin"
    f.write(headers)
    f.write("\n")
    
    # Iterate through each mode of serving payload
    for server, url in source.items():    
        for i in range(1000):
            r = requests.get(url)
            timestamp = datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S.%f')
            row = [
                timestamp, 
                url, 
                server, 
                str(r.elapsed.total_seconds()), 
                str(r.status_code), 
                str(len(r.content)), 
                origin
            ]
            f.write(",".join(row))
            f.write("\n")
            print(i, server, r.elapsed.total_seconds(), r.status_code)
EOF
python3 get_payload.py

