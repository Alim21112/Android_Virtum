import app from './app.js';
import { port } from './config.js';

app.listen(port, '0.0.0.0', () => {
  console.log(`\n🚀 Virtum API running on http://0.0.0.0:${port}`);
  console.log('✅ Listening on ALL network interfaces (accessible from phone)');
  console.log('✅ AI Chat Engine: Ready');
  console.log('✅ Intent Analysis: Enabled');
  console.log('✅ Smart Responses: Active\n');
});
