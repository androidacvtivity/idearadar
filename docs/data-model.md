# IdeaRadar — Initial Data Model

## Idea

- id: UUID
- title: string
- summary: string
- problem: text
- solution: text
- domain: string
- targetUsers: text
- payingCustomer: text
- status: enum
- createdAt: datetime
- updatedAt: datetime
- nextReviewAt: datetime, optional
- archivedAt: datetime, optional

## Evaluation

- id: UUID
- ideaId: UUID
- problemScore: integer 1–5
- marketScore: integer 1–5
- demandScore: integer 1–5
- competitionScore: integer 1–5
- dataAccessScore: integer 1–5
- technicalFeasibilityScore: integer 1–5
- monetizationScore: integer 1–5
- firstClientScore: integer 1–5
- totalScore: calculated integer 8–40
- rationale: text
- evaluatedAt: datetime

## Source

- id: UUID
- ideaId: UUID
- title: string
- url: string, optional
- sourceType: enum
- note: text
- accessedAt: date
- createdAt: datetime

## Note

- id: UUID
- ideaId: UUID
- content: text
- createdAt: datetime
- updatedAt: datetime

## Tag

- id: UUID
- name: string
- color: string, optional

## IdeaTag

- ideaId: UUID
- tagId: UUID

## Decision history

- id: UUID
- ideaId: UUID
- previousStatus: enum, optional
- newStatus: enum
- reason: text
- createdAt: datetime

