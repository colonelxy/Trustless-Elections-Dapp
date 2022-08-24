# Blockchain Hyperledger for elections in Kenya

We all know how tense the general elections get in any part of the world, no matter how advaced their democracy claims to be.

There are always cases and accusations of electoral malpractices, violent responses by opponents and their supporters, and outright vote rigging to win unfairly.

In the Kenyan scenario, many measures have been put in place over the last 2 decades to mitigate some of these challenges. However, more still need to be done especially in the transmission and tallying of the votes peacefully cast.

It's very challenging to rig the election at the voter authentication and voting stages, however, a lot requires to be done in the preceeding stages, transmission and tallying. These last two stages involve technology that can be made more verifyable and trustable to apeace eveeryone involved.

In this small project we will demonstrate the possibility of securing the votes electronically in a transparent system managed by AWS (Amazon Web Services), the world leader in cloud computing.

We will use Kinesis Data Firehorse to capture data transmitted from the KIEMS kit at the polling stations. The data will be securely and openly stored in S3 (cheap data storage) accessible publicly. The data will be processed and it's metadata stored in DynamoDB (a NoSQL database) for analysis and a ledger generated in AWS Managed Blockchain. Hyperledger will make this whole system decentralised and distributed to verified users (electoral candidates, observers, IEBC e.t.c).

Use permisioned private blockchain accessible by a select number of trusted users and major stakeholders.

## 1. Transmission of results
![Transmission](./Images/iot%20main%20plan.png)
### Trust
All peers are identified and verified
Devices only send data from a specific GPS geolocations
committing peers are carefully selected and verified

### Decentralization
Devices can be used as nodes to keep a copy of the ledger
Each peer has a copy of the updated ledger, no single user can make any change


### Security
![authentication](./Images/elections%20iot.png)
Devices are authenticated before sending any results
Each device must have a role assigned to it during the configuration stages so it's the only producer that can send data to the Kinesis Firehorse.
The Kinesis Firehorse too must have a role assigned to it for it to send the collected data to th S3.
Only specific biometrically authenticated persons can send results
Users linked to specific devices

### Operations
One S3 receives and stores the images
An original backup is stored in this first bucket and made ``public read only``
All buckets have delete protection
All changes are logged and traced

## 2. Processing of results
![managed blockchain](./Images/managed%20blockchain.png)
### Trust
The results and analysis are recorded in a publicly available ledge accessible to all registered stakeholders, also known as members or peers. Any of them can compare the end results with the original documents in the first S3 bucket as uploaded by the Iot devices (KIEMS kits).
The logs in the log bucket are immutable and can be used for ausdit purposes, and any changes made by the admin is logged appropriately, no one can ever manipulate the logs forever, thanks to ``AWS QLB`` (Quantum Ledger Blockchain)
### Decentralization
Peers and members make the ecosystem and make this system decentralised. All stakeholders ahve the same copy and no single member can make a change without the others noticing. The will then reject the fraudulent changes and kick out the untrustable member.
Each stakeholder to have a separate VPC (Virtual Private Cloud) liked to the Hyperledger as a client with nodes to make it both distributed and decentralised.
### Security
Specific roles are given to individuals to perform specific duties.
These are managed by AWS IAM.
Iot devices access the AWS ecosystem through specified roles and authenticate via Amazon Cognito that strictly allows access only to verified devices and rejects all other trying to trick or hack into the system to place frauduent results.

Every action takes place within the AWS ecosystem so security of dat is assured. Data is encrypted at rest and during transport.
### Operations

Once transformed, the results are stored as pdf in a second S3
To mitigate the challenge of reading hand written numbers, the sending station should print the data the way cheques are printed with payee details.
This makes it easy for human and the OCR (Optical character recognition) to get the correct details.

Analysis is done to give verifiable provisional results that anyone can access via a public link or API that updates the IEBC public site.
Logs and all modifications are added to the QLB secured cryptographycally and rendered immutable. These logs can be made available on request in case of any doubts by the stakeholders.


## 3. Access to system
### a. Admin Access
Have two admins with full access for redundancy purposes.
### b. Operators Access
Have limited access depending on their speifc duties. 
The roles to be granted through a group access.


### c. Stakeholders Access
### d. Public access
Users can be allowed to see specific data through the shared links



## Voter identification

This too can be secured by linking it to a QLB to log the voting process.
It will ensure voters are marked and analysed once identified and voted. This will help give a clear picture of totall voters, categorised by poling center, constituency and county. Makes it difficult to ammend the total number of votes cast and alert when a person votes more than once.
# Option 2
Just upload the image to S3 as attachment together with an electronic form with the same information.
The e-form is processed further for tallying
The S3 contents have a delete protection.
An audit log is generated and securely kept.
Metadata from the bucket is processed and stored in DynamoDB (NoSql)