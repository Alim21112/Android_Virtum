import express from 'express';
import cors from 'cors';
import { requestLogger } from './middleware/requestLogger.js';
import authRoutes from './routes/auth.js';
import metricsRoutes from './routes/metrics.js';
import chatRoutes from './routes/chat.js';
import healthRoutes from './routes/health.js';

const app = express();

app.use(cors());
app.use(express.json());
app.use(requestLogger);

app.use('/auth', authRoutes);
app.use('/metrics', metricsRoutes);
app.use('/chat', chatRoutes);
app.use('/health', healthRoutes);

export default app;
