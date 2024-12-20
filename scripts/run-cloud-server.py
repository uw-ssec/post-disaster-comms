import boto3
import os
import argparse
from time import sleep

sts = boto3.client('sts')

def sanitize(input):
    return input.lower().strip().replace(" ", "")

project_name = sanitize(os.environ.get('TF_VAR_project_name', 'Support Sphere'))
neighborhood = sanitize(os.environ.get('TF_VAR_neighborhood', 'Laurelhurst'))

resource_prefix = f'{project_name}-{neighborhood}'

scaling_role_arn = f'arn:aws:iam::871683513797:role/{resource_prefix}-scaling-role'
asg_name = f'{resource_prefix}-asg'

def start_session(github):
    if github:
        return boto3.session.Session(region_name='us-west-2')
    
    response = sts.assume_role(
        RoleArn=scaling_role_arn,
        RoleSessionName='run-cloud-server',
    )

    return boto3.session.Session(
        aws_access_key_id=response['Credentials']['AccessKeyId'],
        aws_secret_access_key=response['Credentials']['SecretAccessKey'],
        aws_session_token=response['Credentials']['SessionToken'],
        region_name='us-west-2'
    )

        
def check_current_capacity(autoscaling):
    response = autoscaling.describe_auto_scaling_groups(
        AutoScalingGroupNames=[asg_name]
    )

    current_instances = len(response['AutoScalingGroups'][0]['Instances'])
    desired_capacity = response['AutoScalingGroups'][0]['DesiredCapacity']

    if current_instances == 1:
        if desired_capacity == 1:
            print('Current capacity is 1, and desired capacity is 1')
        else:
            print('Current capacity is 1, but desired capacity is 0.\nASG is in the process of scaling down')
    elif current_instances == 0:
        if desired_capacity == 1:
            print('Current capacity is 0, but desired capacity is 1.\nASG is in the process of scaling up')
        else:
            print('Current capacity is 0, and desired capacity is 0')

    return desired_capacity

def scale_up(autoscaling):
    if check_current_capacity(autoscaling=autoscaling) == 1:
        print('Server is already running')
        return
    
    response = autoscaling.set_desired_capacity(
        AutoScalingGroupName=asg_name,
        DesiredCapacity=1
    )
    print('Scaling up server, it may take a few minutes for the instance to start')


def scale_down(autoscaling):
    if check_current_capacity(autoscaling=autoscaling) == 0:
        print('Server is already stopped')
        return

    response = autoscaling.set_desired_capacity(
        AutoScalingGroupName=asg_name,
        DesiredCapacity=0
    )
    print('Scaling down server, it may take a few minutes for the instance to stop')

def wait_for_scaling(autoscaling, desired_capacity):
    seconds = 0
    while True:
        response = autoscaling.describe_auto_scaling_groups(
            AutoScalingGroupNames=[asg_name]
        )

        if len(response['AutoScalingGroups'][0]['Instances']) == desired_capacity:
            print('Scaling completed')
            if desired_capacity == 1:
                print('InstanceId:', response['AutoScalingGroups'][0]['Instances'][0]['InstanceId'])
            break
        print(seconds, 'seconds elapsed')
        sleep(5)
        seconds += 5



if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run cloud server')
    parser.add_argument('--scale-up', action='store_true', help='Scale up the server by running 1 instance')
    parser.add_argument('--scale-down', action='store_true', help='Scale down the server having 0 instances running')
    parser.add_argument('--replace', action='store_true', help='Replace the server by scaling down and then scaling up')
    parser.add_argument('--github', action='store_true', help='Run the server with github repository')

    args = parser.parse_args() 

    print('Assuming role')
    session = start_session(args.github)
    autoscaling = session.client('autoscaling')
    print('Role assumed')
    if args.scale_up:
        scale_up(autoscaling=autoscaling)
    elif args.scale_down:
        scale_down(autoscaling=autoscaling)
    elif args.replace:
        scale_down(autoscaling=autoscaling)
        wait_for_scaling(autoscaling=autoscaling, desired_capacity=0)
        scale_up(autoscaling=autoscaling)
        wait_for_scaling(autoscaling=autoscaling, desired_capacity=1)