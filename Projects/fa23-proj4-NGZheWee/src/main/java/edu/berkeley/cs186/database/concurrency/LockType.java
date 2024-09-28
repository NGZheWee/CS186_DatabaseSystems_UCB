package edu.berkeley.cs186.database.concurrency;

/**
 * Utility methods to track the relationships between different lock types.
 */
public enum LockType {
    S,   // shared
    X,   // exclusive
    IS,  // intention shared
    IX,  // intention exclusive
    SIX, // shared intention exclusive
    NL;  // no lock held

    /**
     * This method checks whether lock types A and B are compatible with
     * each other. If a transaction can hold lock type A on a resource
     * at the same time another transaction holds lock type B on the same
     * resource, the lock types are compatible.
     */
    public static boolean compatible(LockType a, LockType b) {
        if (a == null || b == null) {
            throw new NullPointerException("null lock type");
        }
        if (a == NL || b == NL) {
            return true;
        } else if (a == IS) {
            return b != X;
        } else if (a == IX){
            return b == IS || b == IX;
        } else if (a == S){
            return b == IS || b == S;
        } else if (a == SIX) {
            return b == IS;
        } else if (a == X) {
            return false;
        }else {
            throw new UnsupportedOperationException();
        }
    }

    /**
     * This method returns the lock on the parent resource
     * that should be requested for a lock of type A to be granted.
     */
    public static LockType parentLock(LockType a) {
        if (a == null) {
            throw new NullPointerException("null lock type");
        }
        switch (a) {
        case S: return IS;
        case X: return IX;
        case IS: return IS;
        case IX: return IX;
        case SIX: return IX;
        case NL: return NL;
        default: throw new UnsupportedOperationException("bad lock type");
        }
    }

    /**
     * This method returns if parentLockType has permissions to grant a childLockType
     * on a child.
     */
    public static boolean canBeParentLock(LockType parentLockType, LockType childLockType) {
        if (parentLockType == null || childLockType == null) {
            throw new NullPointerException("null lock type");
        }
        if (parentLockType == NL){
            return childLockType == NL;
        } else if (parentLockType == IS) {
            return childLockType == NL || childLockType == IS || childLockType == S;
        } else if (parentLockType == IX) {
            return true;
        } else if (parentLockType == S) {
            return childLockType == NL;
        } else if (parentLockType == SIX) {
            return childLockType == NL || childLockType == X || childLockType == IX || childLockType == SIX;
        } else if (parentLockType == X) {
            return childLockType == NL;
        } else {
            throw new UnsupportedOperationException();
        }
    }

    /**
     * This method returns whether a lock can be used for a situation
     * requiring another lock (e.g. an S lock can be substituted with
     * an X lock, because an X lock allows the transaction to do everything
     * the S lock allowed it to do).
     */
    public static boolean substitutable(LockType substitute, LockType required) {
        if (required == null || substitute == null) {
            throw new NullPointerException("null lock type");
        }
        if (substitute == NL) {
            return required == NL;
        } else if (substitute == IS) {
            return required == NL || required == IS;
        } else if (substitute == IX) {
            return required == NL || required == IS || required == IX;
        } else if (substitute == S) {
            return required == NL || required == IS || required == S;
        } else if (substitute == X) {
            return true;
        } else if (substitute == SIX) {
            return required != X;
        } else {
            throw new UnsupportedOperationException();
        }
    }

    /**
     * @return True if this lock is IX, IS, or SIX. False otherwise.
     */
    public boolean isIntent() {
        return this == LockType.IX || this == LockType.IS || this == LockType.SIX;
    }

    @Override
    public String toString() {
        switch (this) {
        case S: return "S";
        case X: return "X";
        case IS: return "IS";
        case IX: return "IX";
        case SIX: return "SIX";
        case NL: return "NL";
        default: throw new UnsupportedOperationException("bad lock type");
        }
    }
}

