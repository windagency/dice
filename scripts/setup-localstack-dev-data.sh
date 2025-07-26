#!/bin/bash
set -e

echo "🚀 Setting up LocalStack Development Data for DICE Project"
echo "=========================================================="

# Check if LocalStack is running
if ! curl -s localhost:4566/_localstack/health > /dev/null; then
    echo "❌ LocalStack is not running. Please start it first:"
    echo "   docker compose up localstack -d"
    exit 1
fi

# Configure AWS CLI for LocalStack
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

echo "📦 Creating S3 Buckets..."
aws --endpoint-url=http://localhost:4566 s3 mb s3://dice-character-portraits || true
aws --endpoint-url=http://localhost:4566 s3 mb s3://dice-campaign-maps || true
aws --endpoint-url=http://localhost:4566 s3 mb s3://dice-rule-documents || true
aws --endpoint-url=http://localhost:4566 s3 mb s3://dice-user-uploads || true

echo "🗄️ Creating DynamoDB Tables..."

# Characters table
echo "  Creating DiceCharacters table..."
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
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
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name DiceCampaigns \
    --attribute-definitions \
        AttributeName=CampaignId,AttributeType=S \
    --key-schema \
        AttributeName=CampaignId,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 > /dev/null || echo "  ⚠️ DiceCampaigns table may already exist"

# Users table
echo "  Creating DiceUsers table..."
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name DiceUsers \
    --attribute-definitions \
        AttributeName=UserId,AttributeType=S \
    --key-schema \
        AttributeName=UserId,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 > /dev/null || echo "  ⚠️ DiceUsers table may already exist"

echo "📝 Adding Sample Data..."

# Sample users
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
    --table-name DiceUsers \
    --item '{
        "UserId": {"S": "user-dm-001"},
        "Username": {"S": "dungeon_master"},
        "Email": {"S": "dm@dice.local"},
        "Role": {"S": "DM"},
        "CreatedAt": {"S": "2025-07-26T21:00:00Z"}
    }' > /dev/null

aws --endpoint-url=http://localhost:4566 dynamodb put-item \
    --table-name DiceUsers \
    --item '{
        "UserId": {"S": "user-player-001"},
        "Username": {"S": "aragorn_player"},
        "Email": {"S": "player1@dice.local"},
        "Role": {"S": "Player"},
        "CreatedAt": {"S": "2025-07-26T21:00:00Z"}
    }' > /dev/null

# Sample characters
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
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
    }' > /dev/null

aws --endpoint-url=http://localhost:4566 dynamodb put-item \
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
    }' > /dev/null

# Sample campaigns
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
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
    }' > /dev/null

echo "📁 Uploading Sample Assets..."

# Create sample files and upload to S3
echo "Gandalf character portrait placeholder" | aws --endpoint-url=http://localhost:4566 s3 cp - s3://dice-character-portraits/gandalf.jpg
echo "Aragorn character portrait placeholder" | aws --endpoint-url=http://localhost:4566 s3 cp - s3://dice-character-portraits/aragorn.jpg
echo "Middle Earth campaign map placeholder" | aws --endpoint-url=http://localhost:4566 s3 cp - s3://dice-campaign-maps/middle-earth.jpg
echo "D&D 5e Player Handbook placeholder" | aws --endpoint-url=http://localhost:4566 s3 cp - s3://dice-rule-documents/players-handbook.pdf

echo ""
echo "✅ LocalStack Development Data Setup Complete!"
echo ""
echo "📊 Summary:"
echo "   🪣 S3 Buckets: 4 created"
echo "   🗄️ DynamoDB Tables: 3 created"
echo "   👤 Sample Users: 2 added"
echo "   🧙 Sample Characters: 2 added"
echo "   🎯 Sample Campaigns: 1 added"
echo "   📁 Sample Assets: 4 uploaded"
echo ""
echo "🔍 Verification Commands:"
echo "   aws --endpoint-url=http://localhost:4566 s3 ls"
echo "   aws --endpoint-url=http://localhost:4566 dynamodb list-tables"
echo "   aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name DiceCharacters"
echo ""
echo "🌐 Access LocalStack Health: http://localhost:4566/_localstack/health" 