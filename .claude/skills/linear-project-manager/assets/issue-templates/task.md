# Task Template

## Objective
[Clear statement of what needs to be accomplished]

**Example**: Migrate user authentication database from PostgreSQL to MongoDB

## Context
[Why is this task needed? What's the background?]

## Checklist
- [ ] [Subtask 1]
- [ ] [Subtask 2]
- [ ] [Subtask 3]
- [ ] [Subtask 4]

**Example**:
- [ ] Export existing user data from PostgreSQL
- [ ] Set up MongoDB instance
- [ ] Write migration script
- [ ] Test migration with sample data
- [ ] Perform production migration
- [ ] Verify data integrity
- [ ] Update application connection strings
- [ ] Monitor for issues

## Dependencies
### Blockers
[What must be completed before this task can start?]

**Examples**:
- ENG-123: Database schema finalized
- ENG-456: Backup system in place

### Blocking
[What other work is waiting for this task?]

**Examples**:
- ENG-789: New feature using MongoDB
- ENG-012: Performance optimization

## Resources
### Documentation
- [Link to relevant docs]
- [Link to technical specs]

### Access/Permissions
- [ ] Database access granted
- [ ] VPN credentials obtained
- [ ] Admin rights confirmed

### Tools/Services
- [List required tools or services]

## Acceptance Criteria
- [ ] [Criterion 1: How do we know this is done correctly?]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

**Example**:
- [ ] All user data successfully migrated
- [ ] Zero data loss verified
- [ ] Application functions normally with new database
- [ ] Migration documented

## Estimated Effort
[Rough time estimate if known]

- **Complexity**: [Simple / Medium / Complex]
- **Time Estimate**: [e.g., 2 hours, 1 day, 1 week]
- **Confidence**: [High / Medium / Low]

## Testing Plan
[How will we verify this task is completed correctly?]

**Example**:
1. Compare record counts before/after migration
2. Run automated test suite
3. Perform manual spot checks on 100 random records
4. Monitor error logs for 24 hours post-migration

## Rollback Plan
[If things go wrong, how do we revert?]

**Example**:
1. Restore from backup taken in step 1
2. Revert application connection strings
3. Restart application servers
4. Verify original functionality restored

## Communication
### Stakeholders to Notify
- [ ] [Person/Team 1]
- [ ] [Person/Team 2]

### When to Notify
- [ ] Before starting task
- [ ] When task is 50% complete
- [ ] When task is complete
- [ ] If issues arise

## Notes
[Any additional information, gotchas, or considerations]

## Definition of Done
- [ ] All checklist items completed
- [ ] Code reviewed (if applicable)
- [ ] Tests passing
- [ ] Documentation updated
- [ ] Stakeholders notified
- [ ] No blocking issues remain
