// Supabase Edge Function: Send FCM Broadcast Notification using HTTP v1 API
// Deploy: supabase functions deploy send-notification

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

// Get service account from environment
const getAccessToken = async () => {
  const CREDENTIALS = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
  
  if (!CREDENTIALS) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT not set')
  }

  const serviceAccount = JSON.parse(CREDENTIALS)
  
  // Create JWT for OAuth 2.0
  const header = { alg: 'RS256', typ: 'JWT' }
  const now = Math.floor(Date.now() / 1000)
  const payload = {
    iss: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  }

  const encoder = new TextEncoder()
  
  // Base64url encode (JWT standard)
  const base64UrlEncode = (str: string) => {
    return btoa(str)
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=/g, '')
  }
  
  const headerB64 = base64UrlEncode(JSON.stringify(header))
  const payloadB64 = base64UrlEncode(JSON.stringify(payload))
  const signatureInput = `${headerB64}.${payloadB64}`

  // Convert PEM private key to ArrayBuffer
  const pemHeader = '-----BEGIN PRIVATE KEY-----'
  const pemFooter = '-----END PRIVATE KEY-----'
  const pemContents = serviceAccount.private_key
    .replace(pemHeader, '')
    .replace(pemFooter, '')
    .replace(/\s/g, '')
  
  const binaryDer = Uint8Array.from(atob(pemContents), c => c.charCodeAt(0))

  // Import private key
  const privateKey = await crypto.subtle.importKey(
    'pkcs8',
    binaryDer,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  )

  // Sign the JWT
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    privateKey,
    encoder.encode(signatureInput)
  )

  const signatureB64 = base64UrlEncode(String.fromCharCode(...new Uint8Array(signature)))
  const jwt = `${signatureInput}.${signatureB64}`

  // Exchange JWT for access token
  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  })

  const data = await response.json()
  return data.access_token
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    })
  }

  try {
    const { title, message, type } = await req.json()

    if (!title || !message) {
      return new Response(
        JSON.stringify({ error: 'Title and message are required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    console.log('Sending FCM v1 broadcast:', { title, type })

    // Get access token
    const accessToken = await getAccessToken()
    const projectId = 'campus-connect-23fae'

    // Send to topic using FCM v1 API
    const fcmResponse = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            topic: 'all_users',
            notification: {
              title: title,
              body: message,
            },
            data: {
              type: type || 'announcement',
              timestamp: Date.now().toString(),
            },
            android: {
              priority: 'high',
              notification: {
                channel_id: 'campus_connect_channel',
                sound: 'default',
              },
            },
            apns: {
              payload: {
                aps: {
                  sound: 'default',
                  badge: 1,
                },
              },
            },
          },
        }),
      }
    )

    const fcmResult = await fcmResponse.json()

    if (fcmResponse.ok) {
      console.log('FCM v1 notification sent:', fcmResult)
      
      return new Response(
        JSON.stringify({
          success: true,
          message: 'Notification sent successfully',
          messageId: fcmResult.name,
        }),
        {
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        }
      )
    } else {
      console.error('FCM v1 error:', fcmResult)
      throw new Error(fcmResult.error?.message || 'Failed to send notification')
    }
  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  }
})
