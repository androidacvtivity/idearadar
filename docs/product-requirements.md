# IdeaRadar — MVP Product Requirements

## 1. Product definition

IdeaRadar helps individuals and small teams capture ideas, add evidence,
evaluate opportunities, and decide what to research, postpone, reject, or
develop.

## 2. Target users

- Independent developers
- Entrepreneurs
- Researchers
- Product managers
- Small innovation teams

## 3. Core workflow

1. Capture an idea.
2. Describe the problem and proposed solution.
3. Identify target users and the paying customer.
4. Attach sources and research notes.
5. Score the opportunity.
6. Assign a status.
7. Review it later and record the decision.

## 4. MVP features

### Idea management

- Create, view, edit, archive, and delete an idea.
- Store title, summary, problem, solution, domain, target users, paying
  customer, notes, and dates.
- Assign tags and a status.

### Evaluation

Each criterion is scored from 1 to 5:

1. Problem severity
2. Market potential
3. Demand evidence
4. Competition favorability
5. Data access
6. Technical feasibility
7. Monetization potential
8. Access to a first client

The total score is calculated automatically out of 40.

### Evidence

- Add source title, URL, source type, access date, and note.
- Add research notes to an idea.
- Distinguish assumptions from verified evidence.

### Discovery and review

- Search by title, domain, tag, or note.
- Filter by status and score.
- Sort by score, creation date, or review date.
- Show highest-scoring ideas on the dashboard.
- Set the next review date.

### Localization

- English is the initial language.
- UI strings must be externalized for Romanian and Russian translations.

## 5. Statuses

- New
- Researching
- Evaluating
- Validated
- On hold
- Rejected
- In development
- Launched

## 6. Screens

1. Dashboard
2. Ideas list
3. Create/edit idea
4. Idea details
5. Evaluation
6. Sources and notes
7. Settings

## 7. Version 1 exclusions

- User accounts
- Cloud synchronization
- Team collaboration
- AI-generated evaluations
- Payments and subscriptions
- Automatic web monitoring
- PHP/MySQL backend

## 8. Acceptance criteria

- The application works without internet.
- A user can create and score an idea in under three minutes.
- Scores are recalculated immediately and consistently.
- Data remains available after restarting the application.
- Lists can be searched, filtered, and sorted.
- Layout works on Samsung Galaxy A16 and iPhone 11.

## 9. Initial test data

The first dataset will use the CPMA Moldova opportunities, including:

- Church/parish white-label app — 30/40
- Agricultural supplier/cooperative portal — 29/40
- Private course center app — 29/40
- Accountant–client portal — 28/40

