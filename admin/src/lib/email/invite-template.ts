interface InviteTemplateInput {
  recipientName: string | null
  identifier: string
  organizationName: string
  organizationType: string
  magicLinkUrl: string
  fallbackCode: string
  appStoreUrl?: string
  contactEmail?: string | null
}

const APP_STORE_URL = 'https://apps.apple.com/app/below-the-surface/id6747486577'

export function renderInviteEmail(input: InviteTemplateInput): { subject: string; html: string; text: string } {
  const {
    recipientName,
    identifier,
    organizationName,
    magicLinkUrl,
    fallbackCode,
    appStoreUrl = APP_STORE_URL,
    contactEmail,
  } = input

  const greeting = recipientName ? `Hello ${escapeHtml(recipientName)},` : 'Hello,'
  const subject = `${organizationName} has given you free access to Below the Surface`

  const html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${escapeHtml(subject)}</title>
</head>
<body style="margin:0;padding:0;background:#f5f7fa;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;color:#1a2332;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f7fa;padding:32px 16px;">
    <tr>
      <td align="center">
        <table width="560" cellpadding="0" cellspacing="0" style="max-width:560px;background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,0.06);">

          <!-- Header -->
          <tr>
            <td style="background:linear-gradient(135deg,#0d2438,#0891b2);padding:40px 32px;text-align:center;">
              <div style="color:rgba(255,255,255,0.85);font-size:13px;font-weight:600;letter-spacing:1.5px;text-transform:uppercase;margin-bottom:8px;">Below the Surface</div>
              <h1 style="color:#ffffff;font-size:24px;font-weight:700;margin:0;line-height:1.3;">You've been given free access</h1>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:32px;">
              <p style="font-size:16px;line-height:1.6;margin:0 0 16px;color:#1a2332;">${greeting}</p>

              <p style="font-size:16px;line-height:1.6;margin:0 0 24px;color:#1a2332;">
                <strong>${escapeHtml(organizationName)}</strong> has covered the cost of a Below the Surface premium subscription for you. There's nothing for you to pay - just tap the button below to activate your access.
              </p>

              <!-- CTA -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin:32px 0;">
                <tr>
                  <td align="center">
                    <a href="${magicLinkUrl}" style="display:inline-block;background:#00d9c4;color:#0d1520;font-weight:600;font-size:16px;padding:16px 32px;border-radius:12px;text-decoration:none;">Activate my access</a>
                  </td>
                </tr>
              </table>

              <!-- Fallback -->
              <div style="background:#f5f7fa;border-radius:12px;padding:20px;margin:24px 0;">
                <div style="font-size:12px;font-weight:600;color:#64748b;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:8px;">If the button doesn't work</div>
                <ol style="margin:0;padding-left:20px;color:#1a2332;font-size:14px;line-height:1.7;">
                  <li>Install Below the Surface from the <a href="${appStoreUrl}" style="color:#0891b2;">App Store</a></li>
                  <li>Open the app and tap "I have an access code"</li>
                  <li>Enter your code: <code style="background:#0d1520;color:#00d9c4;padding:4px 8px;border-radius:4px;font-family:'SF Mono',Menlo,monospace;font-size:14px;letter-spacing:1px;">${escapeHtml(fallbackCode)}</code></li>
                </ol>
              </div>

              <!-- Privacy promise -->
              <div style="background:#ecfeff;border-left:4px solid #0891b2;border-radius:8px;padding:16px 20px;margin:24px 0;">
                <div style="font-weight:600;color:#0d2438;margin-bottom:6px;font-size:14px;">Your privacy is protected</div>
                <div style="font-size:13px;line-height:1.6;color:#0d2438;">
                  Below the Surface will <strong>never</strong> share what you do in the app with ${escapeHtml(organizationName)}. They paid for your access, but they can't see your activity, your moods, your journal, or anything else. Ever.
                </div>
              </div>

              <!-- Don't share -->
              <p style="font-size:13px;line-height:1.6;color:#64748b;margin:24px 0 8px;">
                <strong>This code is just for you.</strong> Your access is tied to the device you first activate it on. Please don't share this email or code with anyone else - if a colleague needs access, ask your welfare officer to invite them directly.
              </p>

              <p style="font-size:13px;line-height:1.6;color:#64748b;margin:8px 0 24px;">
                Issued to: <code style="background:#f1f5f9;padding:2px 6px;border-radius:4px;font-family:'SF Mono',Menlo,monospace;">${escapeHtml(identifier)}</code>
              </p>

              ${contactEmail ? `<p style="font-size:13px;line-height:1.6;color:#64748b;margin:8px 0 0;">Questions? Contact your sponsor at <a href="mailto:${escapeHtml(contactEmail)}" style="color:#0891b2;">${escapeHtml(contactEmail)}</a>.</p>` : ''}
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="padding:24px 32px;background:#f5f7fa;text-align:center;">
              <div style="font-size:12px;color:#64748b;line-height:1.6;">
                Below the Surface - Mental wellbeing companion<br>
                If you didn't expect this email, you can safely ignore it.
              </div>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`

  const text = `${greeting}

${organizationName} has covered the cost of a Below the Surface premium subscription for you.

Activate your access: ${magicLinkUrl}

If the button doesn't work:
1. Install Below the Surface from the App Store: ${appStoreUrl}
2. Open the app and tap "I have an access code"
3. Enter your code: ${fallbackCode}

YOUR PRIVACY IS PROTECTED
Below the Surface will never share what you do in the app with ${organizationName}. They paid for your access, but they can't see your activity, your moods, your journal, or anything else. Ever.

This code is just for you. Your access is tied to the device you first activate it on. Please don't share this email or code with anyone else.

Issued to: ${identifier}
${contactEmail ? `\nQuestions? Contact your sponsor at ${contactEmail}.` : ''}
`

  return { subject, html, text }
}

function escapeHtml(s: string): string {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
}
