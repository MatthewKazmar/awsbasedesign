# awsbasedesign
**Purpose:** To set up a very basic AWS environment that is a small scale version of what a single cloud customer might have.

**Layout:** A simple AWS design, 4 spokes on a transit gateway, with an on-prem VPN connection.

The mgmt VPC has a jump box which is Internet accessible. The other subnets send Internet traffic to the Transit Gateway with the idea that the traffic is funnelled on-prem or to a dedicated firewall VPC.
