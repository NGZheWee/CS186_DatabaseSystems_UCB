package edu.berkeley.cs186.database.concurrency;

import edu.berkeley.cs186.database.TransactionContext;

/**
 * LockUtil is a declarative layer which simplifies multigranularity lock
 * acquisition for the user (you, in the last task of Part 2). Generally
 * speaking, you should use LockUtil for lock acquisition instead of calling
 * LockContext methods directly.
 */
public class LockUtil {
    /**
     * Ensure that the current transaction can perform actions requiring
     * `requestType` on `lockContext`.
     *
     * `requestType` is guaranteed to be one of: S, X, NL.
     *
     * This method should promote/escalate/acquire as needed, but should only
     * grant the least permissive set of locks needed. We recommend that you
     * think about what to do in each of the following cases:
     * - The current lock type can effectively substitute the requested type
     * - The current lock type is IX and the requested lock is S
     * - The current lock type is an intent lock
     * - None of the above: In this case, consider what values the explicit
     *   lock type can be, and think about how ancestor looks will need to be
     *   acquired or changed.
     *
     * You may find it useful to create a helper method that ensures you have
     * the appropriate locks on all ancestors.
     */
    public static void ensureSufficientLockHeld(LockContext lockContext, LockType requestType) {
        // requestType must be S, X, or NL
        assert (requestType == LockType.S || requestType == LockType.X || requestType == LockType.NL);

        // Do nothing if the transaction or lockContext is null
        TransactionContext transaction = TransactionContext.getTransaction();
        if (transaction == null || lockContext == null) return;

        // You may find these variables useful
        LockContext parentContext = lockContext.parentContext();
        LockType effectiveLockType = lockContext.getEffectiveLockType(transaction);
        LockType explicitLockType = lockContext.getExplicitLockType(transaction);

        // TODO(proj4_part2): implement
        // The current lock type can effectively substitute the requested type
        if (LockType.substitutable(effectiveLockType, requestType) || (explicitLockType == LockType.IX && requestType == LockType.S)) {
            if (explicitLockType == LockType.IX && requestType == LockType.S) {
                lockContext.promote(transaction, LockType.SIX);
            }
            return;
        }
        if (explicitLockType.isIntent()) {
            lockContext.escalate(transaction);
            if (lockContext.getEffectiveLockType(transaction) == requestType ||requestType == LockType.S) {
                return;
            }
        }
        helper(requestType != LockType.S ? LockType.IX : LockType.IS, parentContext, transaction);

        if (explicitLockType != LockType.NL) {
            lockContext.promote(transaction, requestType);
        } else {
            lockContext.acquire(transaction, requestType);
        }
    }

    //TODO helper
    public static void helper(LockType lockType, LockContext lockContext, TransactionContext transactionContext) {
        if (lockContext == null) {
            return;
        }
        helper(lockType, lockContext.parentContext(), transactionContext);
        if (!LockType.substitutable(lockContext.getExplicitLockType(transactionContext), lockType)) {
            if (lockContext.getExplicitLockType(transactionContext) != LockType.NL) {
                lockContext.promote(transactionContext, lockType);
            } else {
                lockContext.acquire(transactionContext, lockType);
            }
        }
    }
}
