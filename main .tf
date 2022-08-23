# Blockchain Hyperledger for elections in Kenya

# Use private blockchain accessible by a select number of trusted users and major stakeholders
# Permisioned private
# All peers are identified and verified

# Trust
# Devices only send data from a specific GPS geolocations
# committing peers carefully selected

# Decentralization
# Devices can be used as nodes

# Security
# Devices are authenticated before sending any results
# Only specific biometrically authenticated persons can send results
# Users linked to specific devices

# Ops
# One S3 receives and stores the images
# Once transformed, the results re stored as pdf in a second S3
# All changes are logged and and traced

# Public access
# Users can be allowed to see specific data through the shared links



# Option 2
# Just upload the image to S3 as attachment together with an electronic form with the same information.
# The e-form is processed further for tallying
# The S3 contents have a delete protection.
# An audit log is generated and securely kept.
# Metadata from the bucket is processed and stored in NoSql