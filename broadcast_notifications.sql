-- SQL Function to broadcast notifications to all users
-- This function creates a notification record for each user in the database
-- Usage: SELECT broadcast_notification_to_all_users('event', 'New Event', 'Event description', 'event-123');

CREATE OR REPLACE FUNCTION broadcast_notification_to_all_users(
    p_type TEXT,
    p_title TEXT,
    p_message TEXT,
    p_event_id TEXT DEFAULT NULL
)
RETURNS SETOF notifications AS $$
BEGIN
    -- Insert notification for each user
    RETURN QUERY
    INSERT INTO notifications (
        user_id,
        title,
        message,
        notification_type,
        data,
        is_read,
        created_at
    )
    SELECT 
        auth.users.id,
        p_title,
        p_message,
        p_type,
        jsonb_build_object('event_id', p_event_id),
        false,
        NOW()
    FROM auth.users
    WHERE auth.users.id IS NOT NULL
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION broadcast_notification_to_all_users TO authenticated;

-- Add policy to allow service role to insert notifications for all users
DROP POLICY IF EXISTS "Service can insert notifications for all users" ON notifications;
CREATE POLICY "Service can insert notifications for all users" ON notifications
    FOR INSERT
    WITH CHECK (true);

-- Update existing policy to allow authenticated users to insert notifications
DROP POLICY IF EXISTS "Authenticated users can create notifications" ON notifications;
CREATE POLICY "Authenticated users can create notifications" ON notifications
    FOR INSERT TO authenticated
    WITH CHECK (true);
