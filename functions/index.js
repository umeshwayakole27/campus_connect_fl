/**
 * Firebase Cloud Functions for Campus Connect
 * Handles notification broadcasting to all users
 */

const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {logger} = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp();

/**
 * Send event notification to all users via FCM topic
 * @param {Object} data - {title, body, eventData}
 * @param {Object} context - Authentication context
 */
exports.sendEventNotification = onCall(async (request) => {
  const {data, auth} = request;

  // Check if user is authenticated and is faculty
  if (!auth) {
    throw new HttpsError('unauthenticated', 'User must be authenticated');
  }

  logger.info('Event notification requested by user:', auth.uid);

  // Validate input
  const {title, body, eventData} = data;
  
  if (!title || !body) {
    throw new HttpsError(
      'invalid-argument',
      'Title and body are required'
    );
  }

  try {
    // Create the notification payload
    const payload = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: 'new_event',
        event_id: eventData?.event_id || '',
        event_title: eventData?.event_title || '',
        event_time: eventData?.event_time || '',
        event_location: eventData?.event_location || '',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        timestamp: Date.now().toString(),
      },
      // Android specific config
      android: {
        priority: 'high',
        notification: {
          channelId: 'campus_connect_channel',
          sound: 'default',
          defaultVibrateTimings: true,
          icon: '@mipmap/ic_launcher',
        },
      },
      // iOS specific config
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
            contentAvailable: true,
          },
        },
      },
    };

    // Send to topic 'all_events'
    const response = await admin.messaging().sendToTopic('all_events', payload);

    logger.info('Event notification sent successfully:', {
      messageId: response.messageId,
      title,
      eventId: eventData?.event_id,
    });

    return {
      success: true,
      message: 'Event notification sent successfully',
      messageId: response.messageId,
      successCount: response.successCount || 1,
    };
  } catch (error) {
    logger.error('Error sending event notification:', error);
    throw new HttpsError('internal', 'Failed to send notification: ' + error.message);
  }
});

/**
 * Send broadcast notification to all users via FCM topics
 * @param {Object} data - {title, message, type}
 * @param {Object} context - Authentication context
 */
exports.sendBroadcastNotification = onCall(async (request) => {
  const {data, auth} = request;

  // Check if user is authenticated
  if (!auth) {
    throw new HttpsError('unauthenticated', 'User must be authenticated');
  }

  logger.info('Broadcast notification requested by user:', auth.uid);

  // Validate input
  const {title, message, type} = data;
  
  if (!title || !message) {
    throw new HttpsError(
      'invalid-argument',
      'Title and message are required'
    );
  }

  try {
    // Create the notification payload
    const payload = {
      notification: {
        title: title,
        body: message,
      },
      data: {
        type: type || 'announcement',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        timestamp: Date.now().toString(),
      },
      // Android specific config
      android: {
        priority: 'high',
        notification: {
          channelId: 'campus_connect_channel',
          sound: 'default',
          defaultVibrateTimings: true,
        },
      },
      // iOS specific config
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    // Send to topic 'all_users'
    const response = await admin.messaging().sendToTopic('all_users', payload);

    logger.info('Broadcast notification sent successfully:', {
      messageId: response.messageId,
      title,
      type,
    });

    return {
      success: true,
      message: 'Notification sent successfully',
      messageId: response.messageId,
      successCount: response.successCount || 1,
    };
  } catch (error) {
    logger.error('Error sending broadcast notification:', error);
    throw new HttpsError('internal', 'Failed to send notification: ' + error.message);
  }
});

/**
 * Send notification to specific user by FCM token
 * @param {Object} data - {userId, token, title, message, type}
 */
exports.sendNotificationToUser = onCall(async (request) => {
  const {data, auth} = request;

  if (!auth) {
    throw new HttpsError('unauthenticated', 'User must be authenticated');
  }

  const {token, title, message, type} = data;

  if (!token || !title || !message) {
    throw new HttpsError(
      'invalid-argument',
      'Token, title, and message are required'
    );
  }

  try {
    const payload = {
      notification: {
        title,
        body: message,
      },
      data: {
        type: type || 'notification',
        timestamp: Date.now().toString(),
      },
      token,
    };

    const response = await admin.messaging().send(payload);

    logger.info('Notification sent to user:', {
      messageId: response,
      title,
    });

    return {
      success: true,
      messageId: response,
    };
  } catch (error) {
    logger.error('Error sending notification to user:', error);
    throw new HttpsError('internal', 'Failed to send notification: ' + error.message);
  }
});

/**
 * Send notification to multiple users by FCM tokens
 * @param {Object} data - {tokens[], title, message, type}
 */
exports.sendNotificationToMultiple = onCall(async (request) => {
  const {data, auth} = request;

  if (!auth) {
    throw new HttpsError('unauthenticated', 'User must be authenticated');
  }

  const {tokens, title, message, type} = data;

  if (!tokens || tokens.length === 0 || !title || !message) {
    throw new HttpsError(
      'invalid-argument',
      'Tokens, title, and message are required'
    );
  }

  try {
    const payload = {
      notification: {
        title,
        body: message,
      },
      data: {
        type: type || 'notification',
        timestamp: Date.now().toString(),
      },
    };

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      ...payload,
    });

    logger.info('Notification sent to multiple users:', {
      successCount: response.successCount,
      failureCount: response.failureCount,
      title,
    });

    return {
      success: true,
      successCount: response.successCount,
      failureCount: response.failureCount,
    };
  } catch (error) {
    logger.error('Error sending notification to multiple users:', error);
    throw new HttpsError('internal', 'Failed to send notifications: ' + error.message);
  }
});
