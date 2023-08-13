#!/bin/sh
#Default domain_file
domain_file="/scripts/data/domains.list"
zone_id=$(printenv AWS_ZONE_ID)
dir_log="/scripts/logs"

EchoLog()
{
        msg="$1"
        echo "[$(date '+%d-%m-%Y-%H-%M')]: $msg"
        echo "[$(date '+%d-%m-%Y-%H-%M')]: $msg" >> "$dir_log/domains.log"
}
ValidateIp()
{
        ip_to_check=$1
        message=$2
        if expr "$ip_to_check" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
          IFS=.
          set $ip_to_check
          for quad in 1 2 3 4; do
            if eval [ \$$quad -gt 255 ]; then
              EchoLog "Could not get current IP address: $ip_to_check , exit 1"
              exit 1
            fi
          done
          EchoLog "$message $ip_to_check is valid"
        elif [ "$ip_to_check" = "" ]; then
                EchoLog "$message $ip_to_check not exist"
        else
          EchoLog "Could not get current IP address: $ip_to_check , exit 1"
          exit 1
        fi
}
CreateOrUpdateDnsZone() {
        zone_id="$2"
        domain=$1
        hostname=$domain
        # The AWS id for the zone containing the record, obtained by logging into aws route53
        zoneid=$zone_id
        newip=$(curl -s ifconfig.me)
        ValidateIp "$newip" "New IP"
        # Get the IP address record that AWS currently has, using AWS's DNS server
        oldip=$(dig +short "$hostname")
        ValidateIp "$oldip" "Old IP"
        # Bail if everything is already up to date
        if [ "$newip" = "$oldip" ]; then
                EchoLog "$domain is up to date"
                return 1
        fi
        EchoLog "$domain : change $oldip to $newip"
        tmp=$(mktemp /tmp/dynamic-dns.XXXXXXXX)
        cat > "${tmp}" << EOF
        {
                "Comment": "Auto updating @ $(date)",
                "Changes": [{
                "Action": "UPSERT",
                "ResourceRecordSet": {
                        "ResourceRecords":[{ "Value": "$newip" }],
                        "Name": "$hostname",
                        "Type": "A",
                        "TTL": 300
                }
                }]
        }

EOF
        EchoLog "Changing IP address of $hostname from $oldip to $newip"
        aws route53 change-resource-record-sets --hosted-zone-id "$zoneid" --change-batch "file://$tmp"

        rm "$tmp"
}


if [ ! -f $domain_file ]; then
        EchoLog "Please create a file with domains list"
        exit 1
fi 

grep -v '^ *#' < $domain_file | while IFS= read -r domain
do
        EchoLog "-----------$domain-----------"
        CreateOrUpdateDnsZone "$domain" "$zone_id"
done

exec "$@"

