# awscip

![Github Action](https://github.com/Parcothsai/awscip/actions/workflows/docker_build_multiple_arch.yml/badge.svg?event=push)
![SNYK](https://github.com/Parcothsai/awscip/actions/workflows/snyk_docker_analyse.yml/badge.svg?event=push)


## Description

awscip for aws change ip.

Create or update record to aws route53 on a single domain.

DockerHub url : https://hub.docker.com/r/luninfoparco/awscip

## CLONE THIS PROJECT

```bash
git clone https://github.com/Parcothsai/awscip.git
cd  awscip
```
## Using docker-compose

```bash
# Replace "test" with your correct information
sed -i "s/your_aws_access_key_id/test/g" docker-compose.yml
sed -i "s/your_aws_secret_access_key/test/g" docker-compose.yml
sed -i "s/your_aws_region/test/g" docker-compose.yml
sed -i "s/your_aws_zone_id/test/g" docker-compose.yml

cat > domains.list << EOF 
first.exemple.com
second.exemple.com
EOF
```

Then :
```bash
docker-compose up -d
```

## USING KUBERNETES

### HELM

```bash
# Replace "test" with your correct information
sed -i "s/your_aws_access_key_id/test/g" awscip-chart/values.yaml
sed -i "s/your_aws_secret_access_key/test/g" awscip-chart/values.yaml
sed -i "s/your_aws_region/test/g" awscip-chart/values.yaml
sed -i "s/your_aws_zone_id/test/g" awscip-chart/values.yaml
```

Change in awscip-chart/values.yaml :
```yml
cipDomainsList:
  domainsList: |-
    first.exemple.com
    second.exemple.com
    another.exemple.com
```

Then :
```bash
helm install awscip ./awscip-chart/ --namespace awscip --create-namespace -f ./awscip-chart/values.yaml
```

Exemple of logs :
```bash
[14-04-2023-12-54]: -----------first.exemple.com-----------
[14-04-2023-12-54]: New IP 192.168.1.10 is valid
[14-04-2023-12-54]: Old IP 192.168.1.20 is valid
[14-04-2023-12-54]: first.exemple.com is up to date
[14-04-2023-12-54]: -----------second.exemple.com-----------
[14-04-2023-12-54]: New IP 192.168.1.10 is valid
[14-04-2023-12-54]: Old IP 192.168.1.20 is valid
[14-04-2023-12-54]: second.exemple.com is up to date
[14-04-2023-12-54]: -----------anoter.exemple.com-----------
[14-04-2023-12-54]: New IP 192.168.1.10 is valid
[14-04-2023-12-54]: Old IP 192.168.1.20 is valid
[14-04-2023-12-54]: anoter.exemple.com : change  to 192.168.1.20
{
    "ChangeInfo": {
        "Id": "/change/RANDOM_AWS_ID",
        "Status": "PENDING",
        "SubmittedAt": "2023-04-14T12:54:51.626Z",
        "Comment": "Auto updating @ Fri Apr 14 12:54:50 UTC 2023"
    }
}
```
## Versions

|    name      |     version      |
|:------------:|:----------------:|
|    alpine    |    3.18.0        |
|    python    |    3.11          |
|    pip       |    23.1          |
|    awscli    |    1.27          |
|    curl      |    8.0           |
|    bind      |    9.18          |


## TODO

- :ballot_box_with_check: Add github action to build docker image and push to https://hub.docker.com/r/luninfoparco/awscip
- :x: Add the possibility for a user to have multiple domains
- :ballot_box_with_check: Add kubernetes chart for cronjob