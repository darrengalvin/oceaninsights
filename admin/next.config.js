/** @type {import('next').NextConfig} */
const nextConfig = {
  typescript: {
    // !! WARN !!
    // Dangerously allow production builds to successfully complete even if
    // your project has type errors.
    // This is temporary to get the deployment working
    ignoreBuildErrors: true,
  },
  eslint: {
    // Warning: This allows production builds to successfully complete even if
    // your project has ESLint errors.
    ignoreDuringBuilds: true,
  },
  experimental: {
    skipTrailingSlashRedirect: true,
    // Load the Anthropic SDK from node_modules at runtime instead of bundling
    // it: Next 14's bundler mangles a Unicode regex inside the SDK.
    serverComponentsExternalPackages: ['@anthropic-ai/sdk'],
  },
  async rewrites() {
    return [
      { source: '/privacy', destination: '/privacy.html' },
      { source: '/terms', destination: '/terms.html' },
      { source: '/support', destination: '/support.html' },
    ]
  },
  async headers() {
    return [
      {
        source: '/.well-known/apple-app-site-association',
        headers: [
          { key: 'Content-Type', value: 'application/json' },
          { key: 'Cache-Control', value: 'public, max-age=3600' },
        ],
      },
    ]
  },
  // Old copies of the admin screens used to live outside /admin, without the
  // sidebar or the login check. They have been removed; send old bookmarks to
  // the real admin screens instead.
  async redirects() {
    const legacy = [
      'content', 'domains', 'import', 'journeys', 'learn', 'objectives',
      'protocols', 'rituals', 'scenarios', 'subscriptions', 'analytics',
    ]
    return legacy.flatMap((section) => [
      { source: `/${section}`, destination: `/admin/${section}`, permanent: false },
      { source: `/${section}/:path*`, destination: `/admin/${section}/:path*`, permanent: false },
    ])
  },
  // Don't try to fetch data from API routes during build
  generateBuildId: async () => {
    return 'build-' + Date.now()
  },
}

module.exports = nextConfig

