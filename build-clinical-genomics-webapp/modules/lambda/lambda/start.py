# Author Dolapo Ajayi

import boto3

def lambda_handler(event, context):
    autoscaling = boto3.client('autoscaling')
    
    # Name of the Auto Scaling Group
    asg_name = "internal-webapp-asg"
    
    # Desired capacity to scale up to
    desired_capacity = 2  # Adjust this value as needed
    
    try:
        # Update the desired capacity of the ASG
        response = autoscaling.set_desired_capacity(
            AutoScalingGroupName=asg_name,
            DesiredCapacity=desired_capacity,
            HonorCooldown=True  # Ensures cooldown periods are respected
        )
        print(f"Successfully updated desired capacity of ASG '{asg_name}' to {desired_capacity}.")
    except Exception as e:
        print(f"Error updating desired capacity for ASG '{asg_name}': {e}")