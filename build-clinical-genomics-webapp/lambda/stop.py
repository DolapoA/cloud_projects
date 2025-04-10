import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    filters = [{
        'Name': 'tag:AutoSchedule',
        'Values': ['true']
    }]

    instances = ec2.describe_instances(Filters=filters)
    instance_ids = [i['InstanceId']
                    for r in instances['Reservations']
                    for i in r['Instances']]

    if instance_ids:
        print(f"Stopping instances: {instance_ids}")
        ec2.stop_instances(InstanceIds=instance_ids)
    else:
        print("No instances to stop.")