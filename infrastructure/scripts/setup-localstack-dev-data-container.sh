#!/bin/bash
set -e

echo "🚀 Setting up LocalStack Development Data for DICE Project (Containerised)"
echo "=============================================================================="

# Check if LocalStack is running
if ! docker compose exec localstack curl -s localhost:4566/_localstack/health > /dev/null 2>&1; then
    echo "❌ LocalStack is not running. Please start it first:"
    echo "   docker compose up localstack -d"
    exit 1
fi

# Function to run AWS CLI commands in container
awscli_exec() {
    docker compose run --rm awscli "$@"
}

echo "📦 Creating S3 Buckets..."
awscli_exec awslocal s3 mb s3://dice-character-portraits || true
awscli_exec awslocal s3 mb s3://dice-campaign-maps || true
awscli_exec awslocal s3 mb s3://dice-rule-documents || true
awscli_exec awslocal s3 mb s3://dice-user-uploads || true

echo "🗄️ Creating DynamoDB Tables..."

# Characters table
echo "  Creating DiceCharacters table..."
awscli_exec awslocal dynamodb create-table \
    --table-name DiceCharacters \
    --attribute-definitions \
        AttributeName=UserId,AttributeType=S \
        AttributeName=CharacterId,AttributeType=S \
    --key-schema \
        AttributeName=UserId,KeyType=HASH \
        AttributeName=CharacterId,KeyType=RANGE \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 > /dev/null || echo "  ⚠️ DiceCharacters table may already exist"

# Campaigns table
echo "  Creating DiceCampaigns table..."
awscli_exec awslocal dynamodb create-table \
    --table-name DiceCampaigns \
    --attribute-definitions \
        AttributeName=CampaignId,AttributeType=S \
    --key-schema \
        AttributeName=CampaignId,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 > /dev/null || echo "  ⚠️ DiceCampaigns table may already exist"

# Users table
echo "  Creating DiceUsers table..."
awscli_exec awslocal dynamodb create-table \
    --table-name DiceUsers \
    --attribute-definitions \
        AttributeName=UserId,AttributeType=S \
    --key-schema \
        AttributeName=UserId,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 > /dev/null || echo "  ⚠️ DiceUsers table may already exist"

echo "📝 Adding Sample Data..."

# Sample users
awscli_exec awslocal dynamodb put-item \
    --table-name DiceUsers \
    --item '{
        "UserId": {"S": "user-dm-001"},
        "Username": {"S": "dungeon_master"},
        "Email": {"S": "dm@dice.local"},
        "Role": {"S": "DM"},
        "CreatedAt": {"S": "2025-07-26T21:00:00Z"}
    }' > /dev/null || echo "  ⚠️ Sample user data may already exist"

awscli_exec awslocal dynamodb put-item \
    --table-name DiceUsers \
    --item '{
        "UserId": {"S": "user-player-001"},
        "Username": {"S": "aragorn_player"},
        "Email": {"S": "player1@dice.local"},
        "Role": {"S": "Player"},
        "CreatedAt": {"S": "2025-07-26T21:00:00Z"}
    }' > /dev/null || echo "  ⚠️ Sample user data may already exist"

# Sample characters
awscli_exec awslocal dynamodb put-item \
    --table-name DiceCharacters \
    --item '{
        "UserId": {"S": "user-player-001"},
        "CharacterId": {"S": "char-gandalf"},
        "Name": {"S": "Gandalf the Grey"},
        "Class": {"S": "Wizard"},
        "Level": {"N": "10"},
        "Race": {"S": "Maia"},
        "HitPoints": {"N": "84"},
        "ArmorClass": {"N": "15"},
        "Stats": {
            "M": {
                "Strength": {"N": "12"},
                "Dexterity": {"N": "14"},
                "Constitution": {"N": "16"},
                "Intelligence": {"N": "20"},
                "Wisdom": {"N": "18"},
                "Charisma": {"N": "16"}
            }
        },
        "Equipment": {"L": [
            {"S": "Staff of Power"},
            {"S": "Glamdring"},
            {"S": "Narya (Ring of Fire)"}
        ]},
        "CreatedAt": {"S": "2025-07-26T21:00:00Z"}
    }' > /dev/null || echo "  ⚠️ Sample character data may already exist"

awscli_exec awslocal dynamodb put-item \
    --table-name DiceCharacters \
    --item '{
        "UserId": {"S": "user-player-001"},
        "CharacterId": {"S": "char-aragorn"},
        "Name": {"S": "Aragorn"},
        "Class": {"S": "Ranger"},
        "Level": {"N": "15"},
        "Race": {"S": "Human"},
        "HitPoints": {"N": "142"},
        "ArmorClass": {"N": "18"},
        "Stats": {
            "M": {
                "Strength": {"N": "18"},
                "Dexterity": {"N": "16"},
                "Constitution": {"N": "16"},
                "Intelligence": {"N": "14"},
                "Wisdom": {"N": "15"},
                "Charisma": {"N": "18"}
            }
        },
        "Equipment": {"L": [
            {"S": "Andúril"},
            {"S": "Bow of the Galadhrim"},
            {"S": "Elessar"}
        ]},
        "CreatedAt": {"S": "2025-07-26T21:00:00Z"}
    }' > /dev/null || echo "  ⚠️ Sample character data may already exist"

# Sample campaigns
awscli_exec awslocal dynamodb put-item \
    --table-name DiceCampaigns \
    --item '{
        "CampaignId": {"S": "campaign-lotr"},
        "Name": {"S": "The Lord of the Rings"},
        "Description": {"S": "Epic quest to destroy the One Ring"},
        "DungeonMaster": {"S": "user-dm-001"},
        "Players": {"L": [
            {"S": "user-player-001"}
        ]},
        "Status": {"S": "Active"},
        "SessionCount": {"N": "12"},
        "CreatedAt": {"S": "2025-07-26T20:00:00Z"},
        "LastPlayed": {"S": "2025-07-26T21:00:00Z"}
    }' > /dev/null || echo "  ⚠️ Sample campaign data may already exist"

echo "📁 Uploading Sample Assets..."

# Create sample files locally and upload to S3
echo "Gandalf character portrait placeholder" > /tmp/gandalf.jpg
echo "Aragorn character portrait placeholder" > /tmp/aragorn.jpg
echo "Middle Earth campaign map placeholder" > /tmp/middle-earth.jpg
echo "D&D 5e Player Handbook placeholder" > /tmp/players-handbook.pdf

awscli_exec sh -c "echo 'Gandalf character portrait placeholder' | awslocal s3 cp - s3://dice-character-portraits/gandalf.jpg"
awscli_exec sh -c "echo 'Aragorn character portrait placeholder' | awslocal s3 cp - s3://dice-character-portraits/aragorn.jpg"
awscli_exec sh -c "echo 'Middle Earth campaign map placeholder' | awslocal s3 cp - s3://dice-campaign-maps/middle-earth.jpg"
awscli_exec sh -c "echo 'D&D 5e Player Handbook placeholder' | awslocal s3 cp - s3://dice-rule-documents/players-handbook.pdf"

echo ""
echo "✅ LocalStack Development Data Setup Complete! (Containerised)"
echo ""
echo "📊 Summary:"
echo "   🪣 S3 Buckets: 4 created"
echo "   🗄️ DynamoDB Tables: 3 created"
echo "   👤 Sample Users: 2 added"
echo "   🧙 Sample Characters: 2 added"
echo "   🎯 Sample Campaigns: 1 added"
echo "   📁 Sample Assets: 4 uploaded"
echo ""
echo "🔍 Verification Commands (Containerised):"
echo "   docker compose run --rm awscli awslocal s3 ls"
echo "   docker compose run --rm awscli awslocal dynamodb list-tables"
echo "   docker compose run --rm awscli awslocal dynamodb scan --table-name DiceCharacters"
echo ""
echo "🌐 Access LocalStack Health: https://localhost.localstack.cloud:4566/_localstack/health"
echo ""
echo "💡 Pro Tip: Use 'docker compose run --rm awscli awslocal <command>' for any AWS operations!" 