/**
 * Script para crear colecciones en SolturaDB con validación JSON Schema
 */

// Creación de colecciones

// 1. Colección: media_assets
db.createCollection("media_assets", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["type", "title", "image_url", "description", "migration_date", "guide_link"],
      properties: {
        type: { bsonType: "string" },
        title: { bsonType: "string" },
        image_url: { bsonType: "string" },
        description: { bsonType: "string" },
        migration_date: { bsonType: "date" },
        guide_link: { bsonType: "string" }
      }
    }
  }
});

// 2. Colección: customer_support
db.createCollection("customer_service", {
    validator: {
      $jsonSchema: {
        bsonType: "object",
        required: ["department_name", "contact_channels", "agents", "case_tracking", "satisfaction_survey"],
        properties: {
          department_name: { bsonType: "string" },
          contact_channels: {
            bsonType: "object",
            required: ["phone", "email", "whatsapp", "live_chat", "working_hours"],
            properties: {
              phone: { bsonType: "string" },
              email: { bsonType: "string" },
              whatsapp: { bsonType: "string" },
              live_chat: { bsonType: "bool" },
              working_hours: {
                bsonType: "object",
                properties: {
                  monday_friday: { bsonType: "string" },
                  saturday: { bsonType: "string" },
                  sunday: { bsonType: "string" }
                }
              }
            }
          },
          agents: {
            bsonType: "array",
            items: {
              bsonType: "object",
              required: ["id", "name", "email", "specialty", "languages"],
              properties: {
                id: { bsonType: "string" },
                name: { bsonType: "string" },
                email: { bsonType: "string" },
                specialty: { bsonType: "string" },
                languages: {
                  bsonType: "array",
                  items: { bsonType: "string" }
                }
              }
            }
          },
          case_tracking: {
            bsonType: "object",
            required: ["case_id", "customer_id", "customer_name", "submitted_at", "status", "issue_type", "description", "assigned_agent_id", "last_updated", "resolution", "communication_log"],
            properties: {
              case_id: { bsonType: "string" },
              customer_id: { bsonType: "string" },
              customer_name: { bsonType: "string" },
              submitted_at: { bsonType: "date" },
              status: { bsonType: "string" },
              issue_type: { bsonType: "string" },
              description: { bsonType: "string" },
              assigned_agent_id: { bsonType: "string" },
              last_updated: { bsonType: "date" },
              resolution: {
                bsonType: "object",
                required: ["resolved", "actions_taken"],
                properties: {
                  resolved: { bsonType: "bool" },
                  actions_taken: {
                    bsonType: "array",
                    items: { bsonType: "string" }
                  }
                }
              },
              communication_log: {
                bsonType: "array",
                items: {
                  bsonType: "object",
                  required: ["timestamp", "channel", "message_from", "content"],
                  properties: {
                    timestamp: { bsonType: "date" },
                    channel: { bsonType: "string" },
                    message_from: { bsonType: "string" },
                    content: { bsonType: "string" }
                  }
                }
              }
            }
          },
          satisfaction_survey: {
            bsonType: "object",
            required: ["enabled", "questions", "response_scale"],
            properties: {
              enabled: { bsonType: "bool" },
              questions: {
                bsonType: "array",
                items: { bsonType: "string" }
              },
              response_scale: { bsonType: "string" }
            }
          }
        }
      }
    }
  });


  db.createCollection("content_pages", {
validator: {
    $jsonSchema: {
    bsonType: "object",
    required: ["slug", "title", "sections", "published", "updated_at"],
    properties: {
        slug: { bsonType: "string" },
        title: { bsonType: "string" },
        sections: {
        bsonType: "array",
        items: {
            bsonType: "object",
            required: ["type"],
            properties: {
            type: { bsonType: "string" }, // "text", "image", "banner"
            content: { bsonType: "string" },
            url: { bsonType: "string" },
            alt: { bsonType: "string" },
            title: { bsonType: "string" },
            image_url: { bsonType: "string" },
            start_date: { bsonType: "date" },
            end_date: { bsonType: "date" },
            cta_text: { bsonType: "string" },
            cta_link: { bsonType: "string" }
            }
        }
        },
        published: { bsonType: "bool" },
        updated_at: { bsonType: "date" }
    }
    }
}
});


db.createCollection("promotions", {
    validator: {
      $jsonSchema: {
        bsonType: "object",
        required: ["title", "description", "start_date", "end_date", "active"],
        properties: {
          title: { bsonType: "string" },
          description: { bsonType: "string" },
          start_date: { bsonType: "date" },
          end_date: { bsonType: "date" },
          active: { bsonType: "bool" }
        }
      }
    }
  });

db.createCollection("reviews", {
    validator: {
      $jsonSchema: {
        bsonType: "object",
        required: ["user_id", "provider_id", "rating", "comment", "created_at"],
        properties: {
          user_id: { bsonType: "string" },
          provider_id: { bsonType: "string" },
          rating: { bsonType: "int", minimum: 1, maximum: 5 },
          comment: { bsonType: "string" },
          created_at: { bsonType: "date" }
        }
      }
    }
  });

db.createCollection("faq_articles", {
    validator: {
      $jsonSchema: {
        bsonType: "object",
        required: ["question", "answer", "updated_at"],
        properties: {
          question: { bsonType: "string" },
          answer: { bsonType: "string" },
          related_tags: {
            bsonType: "array",
            items: { bsonType: "string" }
          },
          updated_at: { bsonType: "date" }
        }
      }
    }
  });
  
  

  
