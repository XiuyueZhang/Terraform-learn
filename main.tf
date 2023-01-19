provider "aws"{
    region = "ap-southeast-2"
}

#获取已经存在的资源
data "aws_vpc" "existing-vpc"{
    # argument = filter for query
    default = true
}

# 定义paremeters
variable "cidr-blocks"{
    description = "cidr-blocks and tag names for vpc and subnets"
    type = list(object({
        cidr_block = string
        name = string
    }))
}

resource "aws_vpc" "development-vpc"{
    cidr_block = var.cidr-blocks[0].cidr_block  # 设置ip range
    # 可选值:1-32
    # 数字越小，可以使用的ip越多。32的话只有一个可用ip
    tags = {
        # key:value
        name:var.cidr-blocks[0].name  # 给vpc命名
        vpc_env:"dev"
    }
}

resource "aws_subnet" "dev_subnet_1"{
    vpc_id = aws_vpc.development-vpc.id
    # 基于上面即将要创建的资源进行定义
    cidr_block = var.cidr-blocks[1].cidr_block
    # 给一个上面range里的子网
    availability_zone = "ap-southeast-2a"
    tags = {
        # 所有resources都存在tag属性
        name:var.cidr-blocks[1].name
    }
}

resource "aws_subnet" "dev_subnet_2"{
    vpc_id = data.aws_vpc.existing-vpc.id
    # 已经存在的data获取方式
    cidr_block = "172.31.48.0/20"
    # 需要与现有的ip range不同
    availability_zone = "ap-southeast-2a"
    tags = {
        name: "subnet-2-dev"
    }
}

# 得到不同的attribute需要创建不同的output
output "dev-vpc-id"{
    value = aws_vpc.development-vpc.id
}

output "dev_subnet_1_id"{
    value = aws_subnet.dev_subnet_1.id
}