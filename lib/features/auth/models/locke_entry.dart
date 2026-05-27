class LockeEntry {
  final String id;
  final String title;
  final String username;
  final String password;
  final int hue;

  const LockeEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    required this.hue,
  });
}

const kVaultSeed = <LockeEntry>[
  LockeEntry(id: '1',  title: 'Figma',       username: 'maya.chen@studio.co',  password: r'k7$Bz!9pLqRm2',  hue: 200),
  LockeEntry(id: '2',  title: 'GitHub',       username: 'mchen-dev',            password: 'gh_pat_19fQv',     hue: 270),
  LockeEntry(id: '3',  title: 'Linear',       username: 'maya@studio.co',       password: 'L1n3@r-2025!',     hue: 245),
  LockeEntry(id: '4',  title: 'Notion',       username: 'maya.chen',            password: 'n0t10n-secure',    hue: 30),
  LockeEntry(id: '5',  title: 'AWS Console',  username: 'maya-admin',           password: r'AKIAI8Hx#vQz',   hue: 18),
  LockeEntry(id: '6',  title: '1Password',    username: 'maya.chen@studio.co',  password: 'metaPW.x842',      hue: 215),
  LockeEntry(id: '7',  title: 'Stripe',       username: 'finance@studio.co',    password: 'sk_live_92fGh',    hue: 250),
  LockeEntry(id: '8',  title: 'Vercel',       username: 'mchen',                password: 'V3rc3l-deploy',    hue: 0),
  LockeEntry(id: '9',  title: 'Cloudflare',   username: 'admin@studio.co',      password: 'cf-zone-99x',      hue: 35),
  LockeEntry(id: '10', title: 'Discord',      username: 'maya#4421',            password: 'd1sc0rd!42',       hue: 235),
  LockeEntry(id: '11', title: 'Spotify',      username: 'mayachen',             password: 'sp0t-fam-9',       hue: 145),
  LockeEntry(id: '12', title: 'Apple ID',     username: 'maya.chen@icloud.com', password: 'Ap9!e-id-2024',    hue: 0),
];
