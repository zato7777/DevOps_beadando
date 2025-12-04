import { MainClass } from "./main-class";
import express, { NextFunction, Request, Response } from 'express';
import { configureRoutes } from "./routes/routes";
import bodyParser from "body-parser";
import cookieParser from "cookie-parser";
import expressSession from "express-session";
import passport from "passport";
import { configurePassport } from "./passport/passport";
import mongoose from "mongoose";
import cors from "cors";
import { ErrorRequestHandler } from 'express';


const app = express();
const client = require('prom-client');
const port = 5000;
const dbUrl = process.env.DB_URL || "mongodb://localhost:6000/mongo_db";
const sessionOptions: expressSession.SessionOptions = {
    secret: 'jegyertekesito',
    resave: false,
    saveUninitialized: false
};

const whitelist = ["*", "http://localhost:4200"];
const corsOptions = {
    origin: (origin: string |undefined, callback: (err: Error | null, allowed?: boolean) => void) => {
        if (whitelist.indexOf(origin!) !== -1 || whitelist.includes("*")) {
            callback(null, true);
        } else {
            callback(new Error("Not allowed by CORS!"));
        }
    },
    credentials: true
};

const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics();

mongoose.connect(dbUrl).then((_) => {
    console.log("Succesfully connected to mongodb!");
}).catch(error => {
    console.log(error);
    return;
});

app.use(cors(corsOptions));

app.use(express.json({ limit: '100mb' }));
app.use(express.urlencoded({ extended: true, limit: '100mb' }));

app.use(cookieParser());

app.use(expressSession(sessionOptions));

app.use(passport.initialize());
app.use(passport.session());

configurePassport(passport);

app.use("/app", configureRoutes(passport, express.Router()));
app.use((err: any, req: Request, res: Response, next: NextFunction) => {
    console.error("Error:", err);
    res.status(500).send("Internal server error!");
});

app.get('/metrics', async (req, res) => {
    try {
        res.set('Content-Type', client.register.contentType);
        res.end(await client.register.metrics());
    } catch (e) {
        res.status(500).end(e);
    }
});

const errorHandler: ErrorRequestHandler = (err, req, res, next) => {
    if (err.type === 'entity.too.large') {
      res.status(400).send({ message: 'Upload size is too large!' });
      return;
    }
  
    console.error(err.stack);
    res.status(500).send({ message: 'Internal server error!' });
  };
app.use(errorHandler);

app.listen(port, () => {
    console.log("Server is listening on port " + port.toString() + ".");
});