const AWS = require('aws-sdk');
const ec2 = new AWS.EC2();
const route53 = new AWS.Route53();

exports.handler = async (event) => {
    const instanceId = process.env.INSTANCE_ID;
    const hostedZoneId = process.env.HOSTED_ZONE_ID;
    const domainName = process.env.DOMAIN_NAME;
    
    try {
        // Wait for instance to be running and get its IP
        console.log('Waiting for instance to be running...');
        await ec2.waitFor('instanceRunning', { InstanceIds: [instanceId] }).promise();
        
        // Get the public IP
        const instanceData = await ec2.describeInstances({
            InstanceIds: [instanceId]
        }).promise();
        
        const publicIp = instanceData.Reservations[0].Instances[0].PublicIpAddress;
        
        if (!publicIp) {
            throw new Error(`Failed to get public IP for instance ${instanceId}`);
        }
        
        console.log(`Updating Route53 record with IP: ${publicIp}`);
        
        // Update Route53 record
        await route53.changeResourceRecordSets({
            HostedZoneId: hostedZoneId,
            ChangeBatch: {
                Changes: [{
                    Action: 'UPSERT',
                    ResourceRecordSet: {
                        Name: `sonar.${domainName}`,
                        Type: 'A',
                        TTL: 300,
                        ResourceRecords: [{
                            Value: publicIp
                        }]
                    }
                }]
            }
        }).promise();
        
        console.log('Route53 record updated successfully');
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'Route53 record updated successfully',
                ip: publicIp
            })
        };
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
}; 