// Generated from supabase/*.sql by reading each CREATE TABLE. Regenerate if a table changes.
// Missing from SQL files: []
import type { ColumnDef } from './content-sections'

export const TABLE_COLUMNS: Record<string, ColumnDef[]> = {
  "mood_reasons": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "mood_type",
      "type": "text",
      "required": true
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "daily_brief_energy_levels": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "label",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "daily_brief_objectives": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "category",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "daily_brief_challenges": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "category",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "aar_went_well_options": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "category",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "aar_improve_options": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "category",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "aar_takeaway_options": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "category",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "military_roles": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "branch",
      "type": "text"
    },
    {
      "name": "description",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "civilian_jobs": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text"
    },
    {
      "name": "salary_range",
      "type": "text"
    },
    {
      "name": "growth_outlook",
      "type": "text"
    },
    {
      "name": "key_skills",
      "type": "text",
      "array": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "feelings": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "name",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text",
      "required": true
    },
    {
      "name": "color",
      "type": "text"
    },
    {
      "name": "description",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "coping_tools": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "feeling_id",
      "type": "uuid",
      "ref": "feelings"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text",
      "required": true
    },
    {
      "name": "duration",
      "type": "text"
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "quizzes": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "slug",
      "type": "text",
      "required": true
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text"
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "target_audience",
      "type": "text"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "quiz_questions": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "quiz_id",
      "type": "uuid",
      "ref": "quizzes"
    },
    {
      "name": "question_text",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "quiz_options": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "question_id",
      "type": "uuid",
      "ref": "quiz_questions"
    },
    {
      "name": "option_text",
      "type": "text",
      "required": true
    },
    {
      "name": "result_key",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "quiz_results": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "quiz_id",
      "type": "uuid",
      "ref": "quizzes"
    },
    {
      "name": "result_key",
      "type": "text",
      "required": true
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text"
    },
    {
      "name": "description",
      "type": "text",
      "required": true
    },
    {
      "name": "strengths",
      "type": "text",
      "array": true
    },
    {
      "name": "growth_areas",
      "type": "text",
      "array": true
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "career_paths": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text",
      "required": true
    },
    {
      "name": "tagline",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text",
      "required": true
    },
    {
      "name": "day_in_life",
      "type": "text"
    },
    {
      "name": "skills_needed",
      "type": "text",
      "array": true
    },
    {
      "name": "education_path",
      "type": "text"
    },
    {
      "name": "salary_range",
      "type": "text"
    },
    {
      "name": "color",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "tip_categories": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "slug",
      "type": "text",
      "required": true
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text"
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "accent_color",
      "type": "text"
    },
    {
      "name": "target_audience",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "tips": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "category_id",
      "type": "uuid",
      "ref": "tip_categories"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "content",
      "type": "text",
      "required": true
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "key_points",
      "type": "text",
      "array": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "checklist_templates": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "slug",
      "type": "text",
      "required": true
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text"
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "accent_color",
      "type": "text"
    },
    {
      "name": "target_audience",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "checklist_sections": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "template_id",
      "type": "uuid",
      "ref": "checklist_templates"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "color",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "checklist_items": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "section_id",
      "type": "uuid",
      "ref": "checklist_sections"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "resource_categories": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "slug",
      "type": "text",
      "required": true
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text"
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "accent_color",
      "type": "text"
    },
    {
      "name": "target_audience",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "resource_sections": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "category_id",
      "type": "uuid",
      "ref": "resource_categories"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "resources": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "section_id",
      "type": "uuid",
      "ref": "resource_sections"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text"
    },
    {
      "name": "description",
      "type": "text"
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "details",
      "type": "text",
      "array": true
    },
    {
      "name": "external_url",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "learning_styles": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "name",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text",
      "required": true
    },
    {
      "name": "tips",
      "type": "text",
      "array": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "study_strategies": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "name",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text",
      "required": true
    },
    {
      "name": "best_for",
      "type": "text",
      "array": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "confidence_challenges": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "category",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "affirmations": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "category",
      "type": "text"
    },
    {
      "name": "target_audience",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "confidence_actions": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "category",
      "type": "text"
    },
    {
      "name": "difficulty",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "interest_categories": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "name",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text",
      "required": true
    },
    {
      "name": "color",
      "type": "text"
    },
    {
      "name": "description",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "interest_activities": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "category_id",
      "type": "uuid",
      "ref": "interest_categories"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text",
      "required": true
    },
    {
      "name": "difficulty",
      "type": "text"
    },
    {
      "name": "duration",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "brain_myths": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "statement",
      "type": "text",
      "required": true
    },
    {
      "name": "is_true",
      "type": "boolean"
    },
    {
      "name": "explanation",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "brain_biases": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "scenario",
      "type": "text",
      "required": true
    },
    {
      "name": "correct_option_index",
      "type": "number"
    },
    {
      "name": "explanation",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "brain_bias_options": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "bias_id",
      "type": "uuid",
      "ref": "brain_biases",
      "required": true
    },
    {
      "name": "option_text",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "brain_experiments": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "year",
      "type": "text",
      "required": true
    },
    {
      "name": "researcher",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "brain_experiment_steps": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "experiment_id",
      "type": "uuid",
      "ref": "brain_experiments",
      "required": true
    },
    {
      "name": "step_text",
      "type": "text",
      "required": true
    },
    {
      "name": "step_type",
      "type": "text"
    },
    {
      "name": "options_json",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "body_education_topics": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "tab",
      "type": "text",
      "required": true,
      "options": [
        "female",
        "male"
      ]
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text"
    },
    {
      "name": "colour",
      "type": "text"
    },
    {
      "name": "content",
      "type": "text",
      "required": true
    },
    {
      "name": "normal_range",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "body_education_quiz": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "statement",
      "type": "text",
      "required": true
    },
    {
      "name": "is_fact",
      "type": "boolean",
      "required": true
    },
    {
      "name": "explanation",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "sex_ed_consent_principles": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "letter",
      "type": "text",
      "required": true
    },
    {
      "name": "word",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text",
      "required": true
    },
    {
      "name": "colour",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "sex_ed_consent_scenarios": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "scenario",
      "type": "text",
      "required": true
    },
    {
      "name": "question",
      "type": "text",
      "required": true
    },
    {
      "name": "correct_option_id",
      "type": "text",
      "required": true
    },
    {
      "name": "explanation",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "sex_ed_scenario_options": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "scenario_id",
      "type": "uuid",
      "ref": "sex_ed_consent_scenarios",
      "required": true
    },
    {
      "name": "option_id",
      "type": "text",
      "required": true
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    }
  ],
  "sex_ed_relationship_signs": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "sign_type",
      "type": "text",
      "required": true,
      "options": [
        "healthy",
        "warning"
      ]
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "sex_ed_relationship_rights": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "sex_ed_sti_info": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "name",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text",
      "required": true
    },
    {
      "name": "symptoms",
      "type": "text",
      "required": true
    },
    {
      "name": "treatment",
      "type": "text",
      "required": true
    },
    {
      "name": "prevention",
      "type": "text",
      "required": true
    },
    {
      "name": "treatable",
      "type": "boolean"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "sex_ed_key_facts": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text",
      "required": true
    },
    {
      "name": "content",
      "type": "text",
      "required": true
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "colour",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "bullying_assessment_questions": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "question",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text"
    },
    {
      "name": "subtext",
      "type": "text"
    },
    {
      "name": "step_number",
      "type": "number",
      "required": true
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "bullying_assessment_options": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "question_id",
      "type": "uuid",
      "ref": "bullying_assessment_questions",
      "required": true
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text"
    },
    {
      "name": "tag",
      "type": "text",
      "required": true
    },
    {
      "name": "subtext",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    }
  ],
  "bullying_guidance_cards": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "content",
      "type": "text",
      "required": true
    },
    {
      "name": "action_steps",
      "type": "text",
      "array": true
    },
    {
      "name": "match_tags",
      "type": "text",
      "array": true
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "colour",
      "type": "text"
    },
    {
      "name": "priority",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "bullying_bystander_actions": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text",
      "required": true
    },
    {
      "name": "content",
      "type": "text",
      "required": true
    },
    {
      "name": "examples",
      "type": "text",
      "array": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "bullying_coping_strategies": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text"
    },
    {
      "name": "colour",
      "type": "text"
    },
    {
      "name": "content",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "bullying_support_orgs": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "name",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text",
      "required": true
    },
    {
      "name": "access",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "health_contraception_methods": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "name",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text"
    },
    {
      "name": "category",
      "type": "text",
      "required": true
    },
    {
      "name": "how_it_works",
      "type": "text",
      "required": true
    },
    {
      "name": "effectiveness",
      "type": "text",
      "required": true
    },
    {
      "name": "duration",
      "type": "text",
      "required": true
    },
    {
      "name": "service_notes",
      "type": "text",
      "required": true
    },
    {
      "name": "side_effects",
      "type": "text",
      "array": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "health_pregnancy_topics": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text",
      "required": true
    },
    {
      "name": "content",
      "type": "text",
      "required": true
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "colour",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "harassment_wizard_steps": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text"
    },
    {
      "name": "step_number",
      "type": "number",
      "required": true
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "harassment_wizard_options": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "step_id",
      "type": "uuid",
      "ref": "harassment_wizard_steps",
      "required": true
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text"
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "tag",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "harassment_wizard_guidance": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "message",
      "type": "text",
      "required": true
    },
    {
      "name": "guidance_type",
      "type": "text"
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "priority",
      "type": "number"
    },
    {
      "name": "match_tags",
      "type": "text",
      "array": true
    },
    {
      "name": "is_universal",
      "type": "boolean"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "harassment_wizard_contacts": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "name",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text"
    },
    {
      "name": "phone",
      "type": "text"
    },
    {
      "name": "website",
      "type": "text"
    },
    {
      "name": "availability",
      "type": "text"
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "is_emergency",
      "type": "boolean"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "kindness_flip_cards": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "emoji",
      "type": "text"
    },
    {
      "name": "judgement",
      "type": "text",
      "required": true
    },
    {
      "name": "reality",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "kindness_react_scenarios": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "scenario",
      "type": "text",
      "required": true
    },
    {
      "name": "reveal",
      "type": "text",
      "required": true
    },
    {
      "name": "best_reaction_index",
      "type": "number"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "kindness_react_options": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "scenario_id",
      "type": "uuid",
      "ref": "kindness_react_scenarios",
      "required": true
    },
    {
      "name": "reaction_text",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "lgbtq_timeline": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "year",
      "type": "text",
      "required": true
    },
    {
      "name": "event",
      "type": "text",
      "required": true
    },
    {
      "name": "detail",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "lgbtq_myths": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "myth",
      "type": "text",
      "required": true
    },
    {
      "name": "is_true",
      "type": "boolean"
    },
    {
      "name": "explanation",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "lgbtq_terms": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "term",
      "type": "text",
      "required": true
    },
    {
      "name": "meaning",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "lgbtq_ally_scenarios": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "scenario",
      "type": "text",
      "required": true
    },
    {
      "name": "best_option",
      "type": "number"
    },
    {
      "name": "explanation",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "lgbtq_ally_options": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "scenario_id",
      "type": "uuid",
      "ref": "lgbtq_ally_scenarios"
    },
    {
      "name": "option_text",
      "type": "text",
      "required": true
    },
    {
      "name": "option_index",
      "type": "number"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "lgbtq_deploy_regions": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "region",
      "type": "text",
      "required": true
    },
    {
      "name": "color_hex",
      "type": "text"
    },
    {
      "name": "icon_name",
      "type": "text"
    },
    {
      "name": "countries",
      "type": "text",
      "required": true
    },
    {
      "name": "advice",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "lgbtq_support_orgs": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "name",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text",
      "required": true
    },
    {
      "name": "contact",
      "type": "text",
      "required": true
    },
    {
      "name": "website",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "lgbtq_affirmations": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "perks_facts": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "emoji",
      "type": "text"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "detail",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "perks_regret_stories": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "quote",
      "type": "text",
      "required": true
    },
    {
      "name": "branch",
      "type": "text"
    },
    {
      "name": "years_served",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "mission_objectives": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "category",
      "type": "text",
      "required": true
    },
    {
      "name": "objective_type",
      "type": "text",
      "options": [
        "primary",
        "secondary",
        "contingency"
      ],
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "user_types",
      "type": "text",
      "array": true
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "domains": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "slug",
      "type": "text",
      "required": true
    },
    {
      "name": "name",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text"
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "display_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "journeys": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "slug",
      "type": "text",
      "required": true
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text"
    },
    {
      "name": "audience",
      "type": "text",
      "options": [
        "any",
        "service_member",
        "veteran",
        "partner_family"
      ]
    },
    {
      "name": "item_sequence",
      "type": "uuid",
      "array": true
    },
    {
      "name": "is_published",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "culture_values": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "name",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text"
    },
    {
      "name": "description",
      "type": "text",
      "required": true
    },
    {
      "name": "daily_challenge",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "culture_scenarios": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "scenario",
      "type": "text",
      "required": true
    },
    {
      "name": "correct_value",
      "type": "text",
      "required": true
    },
    {
      "name": "explanation",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "service_family_deployment_phases": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "name",
      "type": "text",
      "required": true
    },
    {
      "name": "timing",
      "type": "text",
      "required": true
    },
    {
      "name": "colour",
      "type": "text"
    },
    {
      "name": "feelings_label",
      "type": "text"
    },
    {
      "name": "feelings",
      "type": "text",
      "required": true
    },
    {
      "name": "tips_label",
      "type": "text"
    },
    {
      "name": "tips",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "service_family_deployment_tips": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text"
    },
    {
      "name": "colour",
      "type": "text"
    },
    {
      "name": "content",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "service_family_understand_topics": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text"
    },
    {
      "name": "colour",
      "type": "text"
    },
    {
      "name": "content",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "service_family_selfcare_strategies": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text"
    },
    {
      "name": "colour",
      "type": "text"
    },
    {
      "name": "content",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "service_family_affirmations": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "text",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "service_family_children_age_groups": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text"
    },
    {
      "name": "colour",
      "type": "text"
    },
    {
      "name": "content",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "service_family_children_tips": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "tip",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "service_family_help_signs": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "sign",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "service_family_support_orgs": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "name",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text",
      "required": true
    },
    {
      "name": "access",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "user_type_screens": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "slug",
      "type": "text",
      "required": true
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text"
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "user_type_sections": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "screen_id",
      "type": "uuid",
      "ref": "user_type_screens"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "user_type_items": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "section_id",
      "type": "uuid",
      "ref": "user_type_sections"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "subtitle",
      "type": "text"
    },
    {
      "name": "icon",
      "type": "text"
    },
    {
      "name": "action_type",
      "type": "text"
    },
    {
      "name": "action_data",
      "type": "text"
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    }
  ],
  "whats_new_releases": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "version",
      "type": "text",
      "required": true
    },
    {
      "name": "title",
      "type": "text"
    },
    {
      "name": "subtitle",
      "type": "text"
    },
    {
      "name": "release_date",
      "type": "date"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ],
  "whats_new_items": [
    {
      "name": "id",
      "type": "uuid"
    },
    {
      "name": "release_id",
      "type": "uuid",
      "ref": "whats_new_releases",
      "required": true
    },
    {
      "name": "emoji",
      "type": "text"
    },
    {
      "name": "title",
      "type": "text",
      "required": true
    },
    {
      "name": "description",
      "type": "text",
      "required": true
    },
    {
      "name": "sort_order",
      "type": "number"
    },
    {
      "name": "is_active",
      "type": "boolean"
    },
    {
      "name": "created_at",
      "type": "timestamp"
    },
    {
      "name": "updated_at",
      "type": "timestamp"
    }
  ]
}

