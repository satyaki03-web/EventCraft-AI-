// netlify/functions/generate-event.js
// Serverless function proxy for Google Gemini API to prevent client-side key exposure

export const handler = async (event, context) => {
  // Only accept POST requests
  if (!event || (event.httpMethod || '').toUpperCase() !== 'POST') {
    return {
      statusCode: 405,
      headers: {
        'Content-Type': 'application/json',
        'Allow': 'POST',
      },
      body: JSON.stringify({ error: 'Method Not Allowed. Only POST requests are accepted.' }),
    };
  }

  try {
    // Parse the prompt string from the incoming event body
    let prompt = '';
    if (typeof event.body === 'string') {
      try {
        const parsed = JSON.parse(event.body || '{}');
        prompt = parsed.prompt || '';
      } catch (parseError) {
        return {
          statusCode: 400,
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ error: 'Invalid JSON payload in request body' }),
        };
      }
    } else if (event.body && typeof event.body === 'object') {
      prompt = event.body.prompt || '';
    }

    if (!prompt) {
      return {
        statusCode: 400,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ error: 'Missing prompt in request body' }),
      };
    }

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new Error('GEMINI_API_KEY environment variable is missing');
    }

    // Securely fetch Google Gemini API
    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;

    const apiResponse = await fetch(geminiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              {
                text: prompt,
              },
            ],
          },
        ],
      }),
    });

    if (!apiResponse.ok) {
      const errorText = await apiResponse.text();
      throw new Error(`Gemini API responded with status ${apiResponse.status}: ${errorText}`);
    }

    const data = await apiResponse.json();

    // Return the AI's JSON response to the client with a 200 status code
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
      },
      body: JSON.stringify(data),
    };
  } catch (error) {
    // Returns a 500 status code and an error message if the API call fails
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        error: error && error.message ? error.message : 'Internal Server Error',
      }),
    };
  }
};

// CommonJS support for environments that invoke handler via require()
if (typeof exports !== 'undefined') {
  exports.handler = handler;
}

export default handler;
