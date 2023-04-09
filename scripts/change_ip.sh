#!/bin/sh

domain_file="/scripts/domains.list"
zone_id=$(printenv AWS_ZONE_ID)
dir_log="/scripts/logs"

CreateOrUpdateDnsZone() {
        zone_id="$2"
        domain=$1
        hostname=$domain
        # The AWS id for the zone containing the record, obtained by logging into aws route53
        zoneid=$zone_id
        newip=$(curl -s ifconfig.me)
        if expr ! "$newip" : "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
        then
                echo "Could not get current IP address: $newip" >> "$dir_log/domains.log"
                exit 1
        fi
        echo "$newip"
        # Get the IP address record that AWS currently has, using AWS's DNS server
        oldip=$(dig +short "$hostname")
        # oldip=$(dig +short "$hostname" @"$nameserver")
        echo "$oldip" >> "$dir_log/domains.log"
        # if  ! expr "$oldip" :  "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
        if  [ ! "$oldip" = "$newip" ]
        then
                echo "$(date) -> $domain : Could not get old ip address" >> "$dir_log/domains.log"
                # exit 1
        fi

        # Bail if everything is already up to date
        if [ "$newip" = "$oldip" ]
        then
                echo "No change need" >> "$dir_log/domains.log"
                echo "$(date) $domain is up to date" >> "$dir_log/domains.log"
                return 1
        fi
        echo "$domain : change $oldip to $newip  on $(date)"
        # aws route53 client requires the info written to a JSON file
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

        echo "Changing IP address of $hostname from $oldip to $newip" >> "$dir_log/domains.log"
        aws route53 change-resource-record-sets --hosted-zone-id "$zoneid" --change-batch "file://$tmp"

        rm "$tmp"
}


if [ ! -f $domain_file ]; then
        echo "Please create a file with domains list" >> "$dir_log/domains.log"
        exit 1
fi 

echo "-----------LOGFILE-----------" >> "$dir_log/domains.log"
grep -v '^ *#' < $domain_file | while IFS= read -r domain
do
        echo "-----------$domain-----------" >> "$dir_log/domains.log"
        CreateOrUpdateDnsZone "$domain" "$zone_id"
done

exec "$@"

