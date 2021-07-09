package terraform.analysis

import input as tfplan

########################
# Parameters for Policy
########################

# Required tags to check for
required_tags = {"tcss:repo"}

# Resource types to check for required tags  
resource_types = {"aws_s3_bucket", "aws_instance", "aws_lambda_function"}



#########
# Policy
#########

# Authorization holds if score for the plan is acceptable and no changes are made to IAM
default tag_enforcement = false
tag_enforcement {
    tag_check
}

# Compute the num of resources that have tags
tag_check = t {
    all := [ x |
            some resource_type
            x := num_tags_found[resource_type]
    ]
    t := sum(all)
    t > 0
}


###################################
# Helper Functions for Policy Check
###################################

# list of all resources of a given type
resources[resource_type] = all {
    some resource_type
    resource_types[resource_type]
    all := [name |
        name:= tfplan.resource_changes[_]
        name.type == resource_type
    ]
}

# number of tags found for resources of a given type
num_tags_found[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    tags_found := [res |  
        res:= all[_] 
        tags:=res.change.after.tags["tcss:repo"]
    ]

    num := count(tags_found)
}
