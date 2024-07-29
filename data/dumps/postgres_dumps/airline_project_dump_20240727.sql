--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2 (Debian 16.2-1.pgdg120+2)
-- Dumped by pg_dump version 16.2 (Debian 16.2-1.pgdg120+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: aircrafts; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.aircrafts (
    aircraftcode character varying(255) NOT NULL,
    airlineequipcode character varying(255),
    names text
);


ALTER TABLE public.aircrafts OWNER TO airline;

--
-- Name: airlines; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.airlines (
    airlineid character varying(10) NOT NULL,
    name text
);


ALTER TABLE public.airlines OWNER TO airline;

--
-- Name: airports; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.airports (
    airportcode character varying(10) NOT NULL,
    citycode character varying(10),
    countrycode character varying(10),
    locationtype character varying(50),
    latitude double precision,
    longitude double precision,
    timezoneid character varying(50),
    utcoffset character varying(10),
    names text
);


ALTER TABLE public.airports OWNER TO airline;

--
-- Name: cities; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.cities (
    citycode character varying(10) NOT NULL,
    countrycode character varying(10),
    name text,
    utcoffset character varying(10),
    timezoneid character varying(50),
    airports text
);


ALTER TABLE public.cities OWNER TO airline;

--
-- Name: countries; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.countries (
    countrycode character varying(10) NOT NULL,
    names text
);


ALTER TABLE public.countries OWNER TO airline;

--
-- Name: experiments; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.experiments (
    experiment_id integer NOT NULL,
    name character varying(256) NOT NULL,
    artifact_location character varying(256),
    lifecycle_stage character varying(32),
    creation_time bigint,
    last_update_time bigint,
    CONSTRAINT experiments_lifecycle_stage CHECK (((lifecycle_stage)::text = ANY ((ARRAY['active'::character varying, 'deleted'::character varying])::text[])))
);


ALTER TABLE public.experiments OWNER TO airline;

--
-- Name: experiments_experiment_id_seq; Type: SEQUENCE; Schema: public; Owner: airline
--

CREATE SEQUENCE public.experiments_experiment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.experiments_experiment_id_seq OWNER TO airline;

--
-- Name: experiments_experiment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airline
--

ALTER SEQUENCE public.experiments_experiment_id_seq OWNED BY public.experiments.experiment_id;


--
-- Name: input_tags; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.input_tags (
    input_uuid character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(500) NOT NULL
);


ALTER TABLE public.input_tags OWNER TO airline;

--
-- Name: inputs; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.inputs (
    input_uuid character varying(36) NOT NULL,
    source_type character varying(36) NOT NULL,
    source_id character varying(36) NOT NULL,
    destination_type character varying(36) NOT NULL,
    destination_id character varying(36) NOT NULL
);


ALTER TABLE public.inputs OWNER TO airline;

--
-- Name: latest_metrics; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.latest_metrics (
    key character varying(250) NOT NULL,
    value double precision NOT NULL,
    "timestamp" bigint,
    step bigint NOT NULL,
    is_nan boolean NOT NULL,
    run_uuid character varying(32) NOT NULL
);


ALTER TABLE public.latest_metrics OWNER TO airline;

--
-- Name: metrics; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.metrics (
    key character varying(250) NOT NULL,
    value double precision NOT NULL,
    "timestamp" bigint NOT NULL,
    run_uuid character varying(32) NOT NULL,
    step bigint DEFAULT '0'::bigint NOT NULL,
    is_nan boolean DEFAULT false NOT NULL
);


ALTER TABLE public.metrics OWNER TO airline;

--
-- Name: model_version_tags; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.model_version_tags (
    key character varying(250) NOT NULL,
    value character varying(5000),
    name character varying(256) NOT NULL,
    version integer NOT NULL
);


ALTER TABLE public.model_version_tags OWNER TO airline;

--
-- Name: model_versions; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.model_versions (
    name character varying(256) NOT NULL,
    version integer NOT NULL,
    creation_time bigint,
    last_updated_time bigint,
    description character varying(5000),
    user_id character varying(256),
    current_stage character varying(20),
    source character varying(500),
    run_id character varying(32),
    status character varying(20),
    status_message character varying(500),
    run_link character varying(500),
    storage_location character varying(500)
);


ALTER TABLE public.model_versions OWNER TO airline;

--
-- Name: params; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.params (
    key character varying(250) NOT NULL,
    value character varying(8000) NOT NULL,
    run_uuid character varying(32) NOT NULL
);


ALTER TABLE public.params OWNER TO airline;

--
-- Name: registered_model_aliases; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.registered_model_aliases (
    alias character varying(256) NOT NULL,
    version integer NOT NULL,
    name character varying(256) NOT NULL
);


ALTER TABLE public.registered_model_aliases OWNER TO airline;

--
-- Name: registered_model_tags; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.registered_model_tags (
    key character varying(250) NOT NULL,
    value character varying(5000),
    name character varying(256) NOT NULL
);


ALTER TABLE public.registered_model_tags OWNER TO airline;

--
-- Name: registered_models; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.registered_models (
    name character varying(256) NOT NULL,
    creation_time bigint,
    last_updated_time bigint,
    description character varying(5000)
);


ALTER TABLE public.registered_models OWNER TO airline;

--
-- Name: runs; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.runs (
    run_uuid character varying(32) NOT NULL,
    name character varying(250),
    source_type character varying(20),
    source_name character varying(500),
    entry_point_name character varying(50),
    user_id character varying(256),
    status character varying(9),
    start_time bigint,
    end_time bigint,
    source_version character varying(50),
    lifecycle_stage character varying(20),
    artifact_uri character varying(200),
    experiment_id integer,
    deleted_time bigint,
    CONSTRAINT runs_lifecycle_stage CHECK (((lifecycle_stage)::text = ANY ((ARRAY['active'::character varying, 'deleted'::character varying])::text[]))),
    CONSTRAINT runs_status_check CHECK (((status)::text = ANY ((ARRAY['SCHEDULED'::character varying, 'FAILED'::character varying, 'FINISHED'::character varying, 'RUNNING'::character varying, 'KILLED'::character varying])::text[]))),
    CONSTRAINT source_type CHECK (((source_type)::text = ANY ((ARRAY['NOTEBOOK'::character varying, 'JOB'::character varying, 'LOCAL'::character varying, 'UNKNOWN'::character varying, 'PROJECT'::character varying])::text[])))
);


ALTER TABLE public.runs OWNER TO airline;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.tags (
    key character varying(250) NOT NULL,
    value character varying(5000),
    run_uuid character varying(32) NOT NULL
);


ALTER TABLE public.tags OWNER TO airline;

--
-- Name: trace_info; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.trace_info (
    request_id character varying(50) NOT NULL,
    experiment_id integer NOT NULL,
    timestamp_ms bigint NOT NULL,
    execution_time_ms bigint,
    status character varying(50) NOT NULL
);


ALTER TABLE public.trace_info OWNER TO airline;

--
-- Name: trace_request_metadata; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.trace_request_metadata (
    key character varying(250) NOT NULL,
    value character varying(8000),
    request_id character varying(50) NOT NULL
);


ALTER TABLE public.trace_request_metadata OWNER TO airline;

--
-- Name: trace_tags; Type: TABLE; Schema: public; Owner: airline
--

CREATE TABLE public.trace_tags (
    key character varying(250) NOT NULL,
    value character varying(8000),
    request_id character varying(50) NOT NULL
);


ALTER TABLE public.trace_tags OWNER TO airline;

--
-- Name: experiments experiment_id; Type: DEFAULT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.experiments ALTER COLUMN experiment_id SET DEFAULT nextval('public.experiments_experiment_id_seq'::regclass);


--
-- Data for Name: aircrafts; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.aircrafts (aircraftcode, airlineequipcode, names) FROM stdin;
100	F100	Fokker 100
141	B461	BAE Systems 146-100 Passenger
142	B462	BAE Systems 146-200 Passenger
143	B463	BAE Systems 146-300 Passenger
14X	B461	BAE Systems 146-100 Freighter
14Y	B462	BAE Systems 146-200 Freighter
14Z	B463	BAE Systems 146-300 Freighter
221	BCS1	Airbus A220-100
223	BCS3	Airbus A220-300
290	E290	E190-E2
295	E295	E195-E2
312	A310	Airbus A310-200 Passenger
313	A310	Airbus A310-300 Passenger
318	A318	Airbus A318
319	A319	Airbus A319
31A	A318	Airbus A318 (sharklets)
31B	A319	Airbus A319 (sharklets)
31N	A19N	Airbus A319neo
31X	A310	Airbus A310-200 Freighter
31Y	A310	Airbus A310-300 Freighter
320	A320	Airbus A320
321	A321	Airbus A321
32A	A320	Airbus A320 (sharklets)
32B	A321	Airbus A321 (sharklets)
32F	A320	Airbus A320 Freighter
32N	A20N	Airbus A320neo
32Q	A21N	Airbus A321neo
32X	A321	Airbus A321 Freighter
332	A332	Airbus A330-200
333	A333	Airbus A330-300
33X	A332	Airbus A330-200 Freighter
342	A342	Airbus A340-200
343	A343	Airbus A340-300
345	A345	Airbus A340-500
346	A346	Airbus A340-600
351	ZZZZ	Airbus A350-1000
358	ZZZZ	Airbus A350-800
359	A359	Airbus A350-900
388	A388	Airbus A380-800 Passenger
38F	A388	Airbus A380-800F Freighter
703	B703	Boeing 707-320B / 320C Passenger
70F	B703	Boeing 707-320B / 320C Freighter
70M	B703	Boeing 707-320B / 320C Mixed Configuration
717	B712	Boeing 717-200
721	B721	Boeing 727-100 Passenger
722	B722	Boeing 727-200 Passenger
72B	B721	Boeing 727-100 Mixed Configuration
72C	B722	Boeing 727-200 Mixed Configuration
72W	B722	Boeing 727-200 (winglets) Passenger
72X	B721	Boeing 727-100 Freighter
72Y	B722	Boeing 727-200 Freighter
731	B731	Boeing 737-100 Passenger
732	B732	Boeing 737-200 Passenger
733	B733	Boeing 737-300 Passenger
734	B734	Boeing 737-400 Passenger
735	B735	Boeing 737-500 Passenger
736	B736	Boeing 737-600 Passenger
738	B738	Boeing 737-800 Passenger
739	B739	Boeing 737-900 Passenger
73C	B733	Boeing 737-300 (winglets) Passenger
73E	B735	Boeing 737-500 (winglets) Passenger
73G	B737	Boeing 737-700 Passenger
73H	B738	Boeing 737-800 (winglets) Passenger/BBJ2
73J	B739	Boeing 737-900 (winglets) Passenger/BBJ3
73L	B732	Boeing 737-200 Mixed Configuration
73N	B733	Boeing 737-300 Mixed Configuration
73P	B734	Boeing 737-400 Freighter
73Q	B734	Boeing 737-400 Mixed Configuration
73R	B737	Boeing 737-700 Mixed Configuration/BBJC
73S	B737	Boeing 737-700 Freighter
73W	B737	Boeing 737-700 (winglets) Passenger/BBJ1
73X	B732	Boeing 737-200 Freighter
73Y	B733	Boeing 737-300 Freighter
741	B741	Boeing 747-100 Passenger
742	B742	Boeing 747-200 Passenger
743	B743	Boeing 747-300 / 747-100/200 SUD Passenger
744	B744	Boeing 747-400 Passenger
748		
74B	B744	Boeing 747-400 Swingtail Freighter
74C	B742	Boeing 747-200 Mixed Configuration
74D	B743	Boeing 747-300 / 747-200 SUD Mixed Configuration
74E	B744	Boeing 747-400 Mixed Configuration
74H	B748	Boeing 747-8 Passenger
74J	B74D	Boeing 747-400 (Domestic) Passenger
74L	B74S	Boeing 747SP Passenger
74N	B748	Boeing 747-8F Freighter
74R	B74R	Boeing 747SR Passenger
74T	B741	Boeing 747-100 Freighter
74U	B743	Boeing 747-300 / 747-200 SUD Freighter
74V	B74R	Boeing 747SR Freighter
74X	B742	Boeing 747-200 Freighter
74Y	B744	Boeing 747-400 Freighter
752	B752	Boeing 757-200 Passenger
753	B753	Boeing 757-300 Passenger
75F	B752	Boeing 757-200 Freighter
75M	B752	Boeing 757-200 Mixed Configuration
75T	B753	Boeing 757-300 (winglets) Passenger
75W	B752	Boeing 757-200 (winglets) Passenger
762	B762	Boeing 767-200 Passenger
763	B763	Boeing 767-300 Passenger
764	B764	Boeing 767-400 Passenger
76V	B763	Boeing 767-300 (winglets) Freighter
76W	B763	Boeing 767-300 (winglets) Passenger
76X	B762	Boeing 767-200 Freighter
76Y	B763	Boeing 767-300 Freighter
772	B77L	Boeing 777-200/ 200ER
773	B773	Boeing 777-300
779	B779	Boeing 777-900
77F	B77F	Boeing 777 Freighter
77L	B772	Boeing 777-200LR
77W	B77W	Boeing 777-300ER
77X	B772	Boeing 777-200F Freighter
783	B783	Boeing 787-3
788	B788	Boeing 787-8
789	B789	Boeing 787-9
A22	AN22	Antonov An-22
A26	AN26	Antonov An-26
A28	AN28	Antonov An-28 / PZL Mielec M-28 Skytruck
A30	AN30	Antonov An-30
A32	AN32	Antonov An-32
A38	AN38	Antonov An-38
A40	A140	Antonov An-140
A4F	A124	Antonov An-124 Ruslan
A58	ZZZZ	Antonov An-158
A5F	A225	Antonov An-225
A81	A148	Antonov AN148-100
AB4	A30B	Airbus A300B2 / A300B4 Passenger
AB6	A306	Airbus A300-600 Passenger
ABB	A3ST	Airbus A300-600ST Beluga Freighter
ABX	A30B	Airbus A300B4 / A300C4 / A300F4 Freighter
ABY	A306	Airbus A300-600 Freighter
ACP	*	Twin Commander Aircraft
ACT	*	Twin (Aero) Turbo Commander / Jetprop Commander
AGH	A109	AgustaWestland A109
AN4	AN24	Antonov An-24
AN7	AN72	Antonov An-72 / An-74
ANF	AN12	Antonov An-12
APF	ZZZZ	BAE Systems  ATP Freighter
APH	*	Eurocopter (Aerospatiale) SA330 Puma / AS332 Super Puma
AR1	RJ1H	Avro RJ100
AR7	RJ70	Avro RJ70
AR8	RJ85	Avro RJ85
AT4	AT43	ATR 42-300 / 320
AT7	AT72	ATR 72
ATF	AT72	ATR 72 Freighter
ATP	ATP	BAE Systems  ATP
ATZ	*	ATR 42 Freighter
AWH	A139	AgustaWestland AW139
AWZ	*	Augusta Westland 200
B12	BA11	BAE Systems (BAC) One-Eleven 200
B13	BA11	BAE Systems (BAC) One-Eleven 300
B14	BA11	BAE Systems (BAC) One-Eleven 400 / 475
B15	BA11	BAE Systems (BAC) One-Eleven 500 / RomBac One-Eleven 560
B72	B720	Boeing 720-020B
BE2	*	Hawker Beechcraft (Light aircraft-twin piston engines)
BE4	BE40	Hawker 400 Beechjet/400A/400XP/400T
BE9	BE99	Hawker Beechcraft C99 Airliner
BEF	B190	Hawker Beechcraft 1900 Freighter
BEH	B190	Hawker Beechcraft 1900D Airliner
BEP	*	Hawker Beechcraft (Light aircraft-single piston engine)
BES	B190	Hawker Beechcraft 1900C Airliner
BET	*	Hawker Beechcraft (Light aircraft-twin turboprop engines)
BH2	*	Bell (Helicopters)
BNI	BN2P	Britten-Norman BN-2A / BN-2B Islander
BNT	TRIS	Britten-Norman BN-2A Mk.III Trislander
BTA	ZZZZ	Business Turbo-Prop Aircraft
BUS	0000	Bus
C27	AJ27	Comac ARJ21-700
CCJ	CL60	Canadair (Bombardier) CL-600 / 601 / 604 / 605 Challenger
CCW	GL5T	Bombardier BD-700 Global 5000
CCX	GLEX	Bombardier BD-700 Global Express
CD2	NOMA	Gippsland Aeronautics N22B / N24A Nomad
CJ1	*	Cessna 500/ 501/ 525 Citation
CJ2	*	Cessna 550/ 551/ 552 Citation
CJ5	*	Cessna 560 Citation
CJ6	*	Cessna 650 Citation
CJ8	*	Cessna 680 Citation
CJL	*	Cessna 560 XL/XLS Citation
CJM	C510	Cessna 510 Mustang Citation
CJX	C750	Cessna 750 Citation X
CL3	CL30	Bombardier Challenger 300
CN1	*	Cessna (Light aircraft-single piston engine)
CN2	*	Cessna (Light aircraft-twin piston engines)
CNC	*	Cessna (Light aircraft-single turboprop engine)
CNF	*	Cessna 208B Freighter
CNJ	*	Cessna Citation
CNT	*	Cessna (Light aircraft-twin turboprop engines)
CR1	CRJ1	Canadair (Bombardier) Regional Jet 100
CR2	CRJ2	Canadair (Bombardier) Regional Jet 200
CR7	CRJ7	Canadair (Bombardier) Regional Jet 700 and Challenger 870
CR9	CRJ9	Canadair (Bombardier) Regional Jet 900 and Challenger 890
CRA	CRJ9	Canadair (Bombardier) Regional Jet 705
CRF	ZZZZ	Canadair (Bombardier) Regional Jet Freighter
CRK	CRJX	Canadair (Bombardier) Regional Jet 1000
CS2	C212	CASA / lAe 212 Aviocar
CS5	CN35	CASA / lAe CN-235
CS9	C295	CASA / lAe C-295
CV2	CVLP	Convair 240 Passenger
CV4	CVLP	Convair 440 Metropolitan Passenger
CV5	CVLT	Convair 580 Passenger
CVV	CVLP	Convair 240 Freighter
CVX	CVLP	Convair 340 / 440 Freighter
CVY	CVLT	Convair 580 / 5800 / 600 / 640 Freighter
CWC	C46	Curtiss C-46 Commando
D11	DC10	Boeing (Douglas) DC-10-10 / 15 Passenger
D1C	DC10	Boeing (Douglas) DC-10-30 / 40 Passenger
D1M	DC10	Boeing (Douglas) DC-10-30 Mixed Configuration
D1X	DC10	Boeing (Douglas) DC-10-10 Freighter
D1Y	DC10	Boeing (Douglas) DC-10-30 / 40 Freighter
D20	F2TH	Dassault Falcon 2000/2000DX
D28	D228	Fairchild Dornier 228
D2L	F2TH	Dassault Falcon 2000EX/EASY/LX
D38	D328	Fairchild Dornier 328-100
D3F	DC3	Boeing (Douglas) DC-3 Freighter
D42	DA42	Diamond Aircraft DA42 Twin Star
D4X	DH8D	De Havilland (Bombardier) DHC-8-400 Dash 8Q Freighter
D6F	DC6	Boeing (Douglas) DC-6A / DC-6B / DC-6C Freighter
D8L	DC86	Boeing (Douglas) DC-8-62 Passenger
D8M	DC86	Boeing (Douglas) DC-8-62 Mixed Configuration
D8Q	DC87	Boeing (Douglas) DC-8-72 Passenger
D8T	DC85	Boeing (Douglas) DC-8-50 Freighter
D8X	DC86	Boeing (Douglas) DC-8-61 / 62 / 63 Freighter
D8Y	DC87	Boeing (Douglas) DC-8-71 / 72 / 73 Freighter
D91	DC91	Boeing (Douglas) DC-9-10 Passenger
D92	DC92	Boeing (Douglas) DC-9-20 Passenger
D93	DC93	Boeing (Douglas) DC-9-30 Passenger
D94	DC94	Boeing (Douglas) DC-9-40 Passenger
D95	DC95	Boeing (Douglas) DC-9-50 Passenger
D9C	DC93	Boeing (Douglas) DC-9-30 Freighter
D9D	DC94	Boeing (Douglas) DC-9-40 Freighter
D9L	F900	Dassault Falcon 900LX
D9X	DC91	Boeing (Douglas) DC-9-10 Freighter
DC3	DC3	Boeing (Douglas) DC-3 Passenger
DC4	DC4	Boeing (Douglas) DC-4
DC6	DC6	Boeing (Douglas) DC-6B Passenger
DF1	FA10	Dassault Falcon 10 / 100
DF2	FA20	Dassault Falcon 20 / 200
DF5	FA50	Dassault Falcon 50 / 50EX
DF7	FA7X	Dassault Falcon 7X
DF9	F900	Dassault Falcon 900/900B/900C/900DX/900EX/EASY
DH1	DH8A	De Havilland (Bombardier) DHC-8-100 Dash 8 / 8Q
DH2	DH8B	De Havilland (Bombardier) DHC-8-200 Dash 8 / 8Q
DH3	DH8C	De Havilland (Bombardier) DHC-8-300 Dash 8 / 8Q
DH4	DH8D	De Havilland (Bombardier) DHC-8-400 Dash 8Q
DH7	DHC7	De Havilland (Bombardier) DHC-7 Dash 7
DHC	DHC4	De Havilland (Bombardier) DHC-4 Caribou
DHD	DOVE	BAE Systems (De Havilland) 104 Dove
DHF	0000	De Havilland (Bombardier) DHC-8 Freighter
DHH	HERN	BAE Systems (De Havilland) 114 Heron
DHL	DH3T	De Havilland (Bombardier) DHC-3 Turbo Otter
DHP	DHC2	De Havilland (Bombardier) DHC-2 Beaver
DHR	DH2T	De Havilland (Bombardier) DHC-2 Turbo Beaver
DHS	DHC3	De Havilland (Bombardier) DHC-3 Otter
DHT	DHC6	De Havilland (Bombardier) DHC-6 Twin Otter
E70	E170	Embraer 170
E75	E170	Embraer 175
E90	E190	Embraer 190
E95	E190	Embraer 195 and Legacy 1000
EA5	EA50	Eclipse 500
EC3	EC30	Eurocopter EC130
EC5	EC55	Eurocopter EC155
EM2	E120	Embraer 120 Brasilia
EMB	E110	Embraer 110 Bandeirante
EP1	E50P	Embraer EMB-500 Phenom 100
EP3	E55P	Embraer EMB-505 Phenom 300
ER3	E135	Embraer RJ135 and Legacy 600/650
ER4	E145	Embraer RJ145
ERD	E135	Embraer RJ140
F21	F28	Fokker F28 Fellowship 1000
F22	F28	Fokker F28 Fellowship 2000
F23	F28	Fokker F28 Fellowship 3000
F24	F28	Fokker F28 Fellowship 4000
F27	F27	Fokker F27 Friendship / Fairchild Industries F-27
F50	F50	Fokker 50
F5F	F50	Fokker 50 Freighter
F70	F70	Fokker 70
FK7	F27	Fairchild Industries FH-227
FRJ	J328	Fairchild Dornier 328JET
G2B	GLF2	Gulfstream Aerospace G-1159 Gulfstream IIB
G2S	GLF2	Gulfstream Aerospace G-1159 Gulfstream IISP
GA8	GA8	Gippsland Aeronautics GA8 Airvan
GJ2	GLF2	Gulfstream Aerospace G-1159 Gulfstream II
GJ3	GLF3	Gulfstream Aerospace G-1159A Gulfstream III
GJ4	GLF4	Gulfstream Aerospace IV (G300/G350/G400/G450/IVSP)
GJ5	GLF5	Gulfstream Aerospace V (G500/G550)
GJ6	GLF6	Gulfstream Aerospace G650
GR1	G150	Gulfstream Aerospace G-100/G-150 (Astra SPX)
GR2	GALX	Gulfstream Aerospace G-200 (Galaxy)
GR3	G280	Gulfstream Aerospace G-280
GRG	G21	Grumman G-21 Goose (Amphibian)
GRM	G73T	Grumman G-73 Turbo Mallard (Amphibian)
H20	PRM1	Hawker 200
H21	H25C	Hawker 1000
H24	HA4T	Hawker 4000
H25	H25B	Hawker 750/800/800XP/800SP
H28	H25B	Hawker 850XP/900
H29	H25B	Hawker 900XP
HEC	COUR	Helio H-250 Courier / H-295 / 395 Super Courier
HOV	0000	Surface Equipment-Hovercraft
HS7	A748	BAE Systems (Hawker Siddeley) 748 / Andover
I14	I114	Ilyushin Il-114
I9F	IL96	Ilyushin Il-96 Freighter
IL6	IL62	Ilyushin Il-62
IL7	IL76	Ilyushin Il-76
IL8	IL18	Ilyushin Il-18
IL9	IL96	Ilyushin Il-96 Passenger
ILW	IL86	Ilyushin Il-86
J31	JS31	BAE Systems Jetstream 31
J32	JS32	BAE Systems Jetstream 32
J41	JS41	BAE Systems Jetstream 41
JU5	JU52	Junkers Ju 52/3m
L11	L101	Lockheed Martin L-1011 TriStar 1 / 50 / 100 / 150 / 200 / 250 Passenger
L15	L101	Lockheed Martin L-1011 TriStar 500 Passenger
L1F	L101	Lockheed Martin L-1011 TriStar Freighter
L4F	L410	Aircraft Industries (LET) 410 Freighter
L4T	L410	Aircraft Industries (LET) 410
LCH	0000	Surface Equipment-Launch / Boat
LJA	ZZZZ	Light Jet Aircraft
LMO	0000	Surface Equipment-Limousine
LOE	L188	Lockheed Martin L-188 Electra
LOF	L188	Lockheed Martin L-188 Electra Freighter
LOH	C130	Lockheed Martin L-182 / L-282 / L-382 (L-100) Hercules
LRJ	*	Learjet
M11	MD11	Boeing (Douglas) MD-11 Passenger
M1F	MD11	Boeing (Douglas) MD-11 Freighter
M1M	MD11	Boeing (Douglas) MD-11 Mixed Configuration
M2F	MD82	Boeing (Douglas) MD82 Freighter
M3F	MD83	Boeing (Douglas) MD83 Freighter
M81	MD81	Boeing (Douglas) MD-81
M82	MD82	Boeing (Douglas) MD-82
M83	MD83	Boeing (Douglas) MD-83
M87	MD87	Boeing (Douglas) MD-87
M88	MD88	Boeing (Douglas) MD-88
M8F	MD88	Boeing (Douglas) MD88 Freighter
M90	MD90	Boeing (Douglas) MD-90
MA6	AN24	Xian Yunshuji MA-60/MA600
MBH	B105	Eurocopter (MBB) BO105
MD9	EXPL	MD Helicopters Inc MD 900 Explorer
MIH	MI8	Mil Mi-8 / Mi-17 / Mi-171 / Mi-172
MU2	MU2	Mitsubishi Aircraft Corporation MU-2
NDC	S601	Aerospatiale SN601 Corvette
NDE	*	Eurocopter (Aerospatiale) AS350 Ecureuil / AS355 Ecureuil 2
NDH	*	Eurocopter (Aerospatiale) SA365C / SA365N  Dauphin 2
P18	P180	Piaggio Aero P180 Avanti II
PA1	*	Piper (Light aircraft-single piston engine)
PA2	*	Piper (Light aircraft-twin piston engines)
PAT	*	Piper (Light aircraft-twin turboprop engines)
PL2	PC12	Pilatus PC-12
PL6	PC6T	Pilatus PC-6 Turbo Porter
PN6	P68	Vulcanair (Partenavia) P.68
PR1	PRM1	Hawker 390 Premier 1/1A
RFS	0000	Surface Equipment-Road Feeder Service (Truck)
S20	SB20	Saab 2000
S58	S58T	Sikorsky S-58T
S61	S61	Sikorsky S-61
S76	S76	Sikorsky S-76
SF3	SF34	Saab 340
SFB	SF34	Saab 340B
SFF	SF34	Saab 340 Freighter
SH3	SH33	Shorts 330 (SD3-30)
SH6	SH36	Shorts 360 (SD3-60)
SHS	SC7	Shorts Skyvan (SC-7)
SU7	ZZZZ	Sukhoi Superjet 100-75
SU9	SU95	Sukhoi Superjet 100-95
SWF	*	Fairchild (Swearingen) SA226 Freighter
SWM	*	Fairchild (Swearingen) SA26 / SA226 / SA227 Merlin / Metro / Expediter
SY8	AN12	Shaanxi Y-8
T20	T204	Tupolev Tu-204 / Tu-214
T2F	T204	Tupolev Tu-204 Freighter
T34	T334	Tupolev Tu-334
TBM	TBM7	SOCATA TBM-700
TRN	0000	Train
TRS	0000	Train
TU3	T134	Tupolev Tu-134
TU5	T154	Tupolev Tu-154
WWP	WW24	Israel Aerospace Industries 1124 Westwind
YK2	YK42	Yakovlev Yak-42 / Yak-142
YK4	YK40	Yakovlev Yak-40
YN2	Y12	Harbin Yunshuji Y12
YN7	AN24	Xian Yunshuji Y7
YS1	YS11	NAMC YS-11
\.


--
-- Data for Name: airlines; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.airlines (airlineid, name) FROM stdin;
0	AirOneAtlantic
0A	AmberAir
0B	BlueAir
0D	DarwinAirline
0J	Jetclub
0X	CopenhagenExpress
1	BobbAirFreight
10	CanadianWorld
11	TUIfly(X3)
12	12North
13	EasternAtlanticVirtualAirlines
1A	AmadeusGlobalTravelDistribution
1B	AbacusInternational
1C	OneChina
1D	RadixxSolutionsInternational
1E	TravelskyTechnology
1F	CBAirwaysUK(InterligingFlights)
1G	GalileoInternational
1H	HellenicAirways
1I	SkyTrekInternationalAirlines
1K	Sutra
1L	OpenSkiesConsultativeCommission
1M	JSCTransportAutomatedInformationSystems
1N	Navitaire
1P	Worldspan
1Q	Sirena
1R	HainanPhoenixInformationSystems
1S	Sabre
1T	1TimeAirline
1U	PolyotSirena
1Z	SabrePacific
20	AirSalone
24	EuroJet
2A	DeutscheBahn
2B	Aerocondor
2C	SNCF
2D	AeroVIP(2D)
2F	FrontierFlyingService
2G	SanJuanAirlines
2H	Thalys
2I	StarPeru(2I)
2J	AirBurkina
2K	AerolineasGalapagos(Aerogal)
2L	HelveticAirways
2M	MoldavianAirlines
2N	NextJet
2O	AirSalone
2P	AirPhilippines
2Q	AirCargoCarriers
2R	VIARailCanada
2S	StarEquatorialAirlines
2T	HaitiAmbassadorAirlines
2U	AirGuineeExpress
2W	WelcomeAir
2X	RegionaliaUruguay
2Z	ChanganAirlines
3B	JobAir
3C	RegionsAir
3E	AirChoiceOne
3F	FlyColombia(InterligingFlights)
3G	Atlant-SoyuzAirlines
3I	AirCometChile
3J	Zip
3K	JetstarAsiaAirways
3L	Intersky
3N	AirUrga
3O	AirArabiaMaroc
3P	TiaraAir
3Q	YunnanAirlines
3R	MoskoviaAirlines
3S	AirAntillesExpress
3T	TuranAir
3U	SichuanAirlines
3V	3ValleysAirlines
3W	MalawianAirlines
4	AntrakAir
47	88
4A	AirKiribati
4C	Aires
4D	AirSinai
4F	AirCity
4G	Gazpromavia
4H	UnitedAirways
4K	AskariAviation
4L	Euroline
4M	LANArgentina
4N	AirNorthCharter-Canada
4O	Interjet(ABCAerolineas)
4P	BusinessAviation
4Q	SafiAirlines
4R	HamburgInternational
4S	FinalairCongo
4T	BelairAirlines
4U	Germanwings
4X	RedJetMexico
4Y	AirbusFrance
4Z	Airlink(SAA)
5A	AlpineAirExpress
5C	CALCargoAirLines
5D	DonbassAero
5E	SGAAirlines
5F	ArcticCircleAirService
5G	SkyserviceAirlines
5H	Fly540
5J	CebuPacific
5K	HiFly(5K)
5L	Aerosur
5M	Sibaviatrans
5N	Aeroflot-Nord
5P	Palairlines
5Q	BQBLineasAereas
5T	CanadianNorth
5V	LvivAirlines
5W	Astraeus
5X	UnitedParcelService
5Y	AtlasAir
5Z	VivaColombia
69	RoyalEuropeanAirlines
6A	ConsorcioAviaxsa
6B	TUIflyNordic
6C	VuelaCuba
6D	Pelita
6E	IndiGoAirlines
6F	MATAirways
6G	AirWales
6H	Israir
6I	Fly6ix
6J	SkynetAsiaAirways
6K	AsianSpirit
6N	NordicRegional
6P	GryphonAirlines
6Q	SlovakAirlines
6R	AlrosaMirnyAirEnterprise
6T	AirMandalay
6U	AirCargoGermany
6V	MarsRK
6W	SaratovAviationDivision
6Y	SmartLynxAirlines
6Z	UkrainianCargoAirways
7	SamuraiAirlines
76	Southjet
77	Southjetconnect
78	Southjetcargo
7A	AztecWorldwideAirlines
7B	KrasnojarskyAirlines
7C	JejuAir
7E	AerolineGmbH
7F	FirstAir
7G	StarFlyer
7H	EraAlaska
7I	InselAir(7I/INC)(Priv)
7J	TajikAir
7K	KogalymaviaAirCompany
7L	SunD'Or
7M	MongolianInternationalAirLines
7N	Centavia
7O	AllColombia
7P	MetroBatavia
7Q	PanAmWorldAirwaysDominicana
7R	BRA-TransportesAereos
7T	TobrukAir
7W	Wayraper
7Y	MedAirways
7Z	Halcyonair
88	AllAustralia
8A	AtlasBlue
8B	BusinessAir
8C	ShanxiAirlines
8D	ServantAir
8E	BeringAir
8F	STPAirways
8H	HeliFrance
8I	MywayAirlines
8J	Komiinteravia
8K	Voestar
8L	RedhillAviation
8M	MyanmarAirwaysInternational
8N	BarentsAirLink
8O	WestCoastAir
8P	PacificCoastalAirline
8Q	MaldivianAirTaxi
8R	TRIPLinhasA
8S	ScorpioAviation
8T	AirTindi
8U	AfriqiyahAirways
8V	WrightAirService
8W	PrivateWingsFlugcharter
8Y	ChinaPostalAirlines
8Z	WizzAirHungary
8z	LineaAereadeServicioEjecutivoRegional
99	CiaoAir
9A	AllAfrica
9C	ChinaSSS
9E	PinnacleAirlines
9F	TrammAirlines
9H	MDLRAirlines
9I	ThaiSkyAirlines
9J	RegionaliaChile
9K	CapeAir
9L	ColganAir
9N	RegionalAirIceland
9O	NationalAirwaysCameroon
9P	Pelangi
9Q	PBAir
9R	SATENA
9S	SpringAirlines
9T	TranswestAir
9U	AirMoldova
9W	JetAirways
9X	RegionaliaVenezuela
9Y	AirKazakhstan
;;	WildernessAir
??	BritishAirFerries
A1	Atifly
A2	AllAmerica
A3	AegeanAirlines
A4	SouthernWindsAirlines
A5	Airlinair
A6	AirAlpsAviation(A6)
A7	AirPlusComet
A8	BeninGolfAir
A9	GeorgianAirways
AA	AmericanAirlines
AB	AirBerlin
AC	AirCanada
AD	Azul
AE	MandarinAirlines
AF	AirFrance
AG	AirContractors
AH	AirAlgerie
AI	AirIndiaLimited
AJ	AeroContractors
AK	AirAsia
AL	Transaviaexport
AM	AeroMéxico
AN	AnsettAustralia
AO	Avianova(Russia)
AP	AirOne
AQ	AlohaAirlines
AR	AerolineasArgentinas
AS	AlaskaAirlines
AT	RoyalAirMaroc
AU	AustralLineasAereas
AV	Avianca-AeroviasNacionalesdeColombia
AW	AsianWingsAirways
AX	TransStatesAirlines
AY	Finnair
AZ	Alitalia
B0	Awsexpress
B1	BalticAirlines
B2	BelaviaBelarusianAirlines
B3	BellviewAirlines
B4	Flyglobespan
B5	Flightline
B6	JetBlueAirways
B7	UniAir
B8	EritreanAirlines
B9	AirBangladesh
BA	BritishAirways
BB	SeaborneAirlines
BC	SkymarkAirlines
BD	bmi
BE	Flybe
BF	BluebirdCargo
BG	BimanBangladeshAirlines
BH	Hawkair
BI	RoyalBruneiAirlines
BJ	NouvelAirTunisie
BK	PotomacAir
BL	JetstarPacific
BM	bmiregional
BN	HorizonAirlines
BO	BouraqIndonesiaAirlines
BP	AirBotswana
BQ	BuquebusLíneasAéreas
BR	EVAAir
BS	BritishInternationalHelicopters
BT	AirBaltic
BU	BaikotovitchestrianAirlines
BV	BluePanoramaAirlines
BW	CaribbeanAirlines
BX	AirBusan
BY	Thomsonfly
BZ	BlackStallionAirways
C0	Centralwings
C1	CanXpress
C2	CanXplorer
C3	QatXpress
C4	LionXpress
C5	CommutAir
C6	CanJet
C7	SkyWingPacific
C8	ChicagoExpress(C8)
C9	CirrusAirlines
CA	AirChina
CB	CCMLAirlines
CC	MacairAirlines
CD	AirIndiaRegional
CE	NationwideAirlines
CF	CityAirline
CG	AirlinesPNG
CH	BemidjiAirlines
CI	ChinaAirlines
CJ	BACityFlyer
CK	ChinaCargoAirlines
CL	LufthansaCityLine
CM	CopaAirlines
CN	CanadianNationalAirways
CO	ContinentalExpress
CP	CompassAirlines
CQ	SOCHIAIR
CR	AirOps
CS	ContinentalMicronesia
CT	AlitaliaCityliner
CU	CubanadeAviación
CV	Cargolux
CW	AirMarshallIslands
CX	CathayPacific
CY	CyprusAirways
CZ	ChinaSouthernAirlines
D1	DomenicanAirlines
D3	DaalloAirlines
D4	Alidaunia
D5	NEPCAirlines
D6	InterairSouthAfrica
D7	AirAsiaX
D8	DjiboutiAirlines
D9	Aeroflot-Don
DA	DanaAir
DB	BritAir
DC	GoldenAir
DD	NokAir
DE	CondorFlugdienst
DF	MichaelAirlines
DG	SouthEastAsianAirlines
DH	DennisSky
DI	dba
DJ	VirginBlue
DK	EastlandAir
DL	DeltaAirLines
DM	Maersk
DN	SenegalAirlines
DO	DominicanadeAviaci
DP	FirstChoiceAirways
DQ	CoastalAir
DR	AirMediterranee
DS	EasyJet(DS)
DT	TAAGAngolaAirlines
DU	HemusAir
DV	ScatAir
DW	DeutscheLuftverkehrsgesellschaft
DX	DATDanishAirTransport
DY	NorwegianAirShuttle
DZ	Starline.kz
E0	EosAirlines
E1	UsaSkyCargo
E2	RioGrandeAir
E3	DomodedovoAirlines
E4	ElysianAirlines
E5	AirArabiaEgypt
E6	Aviaexpresscruise
E7	EuropeanAviationAirCharter
E8	USAfricaAirways
E9	CompagnieAfricained\\\\'Aviation
EA	EuropeanAirExpress
EC	AvialeasingAviationCompany
ED	Airblue
EE	AeroAirlines
EF	FarEasternAirTransport
EG	JapanAsiaAirways
EH	EuroHarmony
EI	AerLingus
EJ	NewEnglandAirlines
EK	Emirates
EL	AirNippon
EM	EmpireAirlines
EN	AirDolomiti
EO	HewaBoraAirways
EP	IranAsemanAirlines
EQ	TAME
ER	FlyEuropa
ES	EuropeSky
ET	EthiopianAirlines
EU	EmpresaEcuatorianaDeAviacion
EV	AtlanticSoutheastAirlines
EW	Eurowings
EX	AirSantoDomingo
EY	EtihadAirways
EZ	SunAirofScandinavia
F1	FlyBrasil
F2	FlyAir
F3	FasoAirways
F4	AlbarkaAir
F5	GlobalFreightways
F6	Faroejet
F7	Flybaboo
F8	Air2there
F9	FrontierAirlines
FA	EpicHoliday
FB	BulgariaAir
FC	FinncommAirlines
FD	ThaiAirAsia
FE	PrimarisAirlines
FF	TowerAir
FG	ArianaAfghanAirlines
FH	FlyHighAirlinesIreland(FH)
FI	Icelandair
FJ	AirPacific
FK	AfricaWest
FL	AirTranAirways
FM	ShanghaiAirlines
FN	RegionalAirlines
FO	AirlinesOfTasmania
FP	FreedomAir
FQ	ThomasCookAirlines
FR	Ryanair
FS	ServiciosdeTransportesA
FT	SiemReapAirways
FU	FelixAirways
FV	Rossiya-RussianAirlines
FW	IbexAirlines
FX	FederalExpress
FY	NorthwestRegionalAirlines
FZ	FlyDubai
G0	GhanaInternationalAirlines
G1	IndyaAirlineGroup
G2	Avirex
G3	SkyExpress
G4	AllegiantAir
G5	Huaxia
G6	AirVolga
G7	GoJetAirlines
G8	GujaratAirways
G9	AirArabia
GA	GarudaIndonesia
GB	BRAZILAIR
GC	LinaCongo
GD	GoDutch
GE	TransAsiaAirways
GF	GulfAirBahrain
GG	Cargo360
GH	Globus
GI	ItekAir
GJ	EuroflyService
GK	Genesis
GL	MiamiAirInternational
GM	GermanInternationalAirLines
GN	GNBLinhasAereas
GO	KuzuAirlinesCargo
GP	GadairEuropeanAirlines
GQ	BigSkyAirlines
GR	GeminiAirCargo
GS	GrantAviation
GT	GBAirways
GU	Gulisanoairways
GV	AeroFlight
GW	KubanAirlines
GX	Pacificair
GY	GabonAirlines
GZ	AirRarotonga
H1	HankookAirUS
H2	SkyAirline
H3	HarbourAir(Priv)
H4	InterIslandsAirlines
H5	I-Fly
H6	HagelandAviationServices
H7	EagleAir
H8	Dalavia
H9	PEGASUSAIRLINES-
HA	HawaiianAirlines
HB	HarborAirlines
HC	HimalayanAirlines
HD	HokkaidoInternationalAirlines
HE	LuftfahrtgesellschaftWalter
HF	Hapagfly
HG	Niki
HH	AirHamburg(AHO)
HI	PapillonGrandCanyonHelicopters
HJ	AsianExpressAirlines
HK	YangonAirways
HM	AirSeychelles
HN	HankookAirline
HO	JuneyaoAirlines
HP	PhoenixAirways
HQ	HQ-BusinessExpress
HR	HahnAir
HT	HellenicImperialAirways
HU	HainanAirlines
HV	TransaviaHolland
HW	North-WrightAirways
HX	HongKongAirlines
HY	UzbekistanAirways
HZ	SatAirlines
I2	IberiaExpress
I4	InterstateAirline
I5	IndonesiaSky
I6	MexicanaLink
I7	ParamountAirways
I8	IzAvia
I9	Indigo
IA	IraqiAirways
IB	IberiaAirlines
IC	IndianAirlines
ID	InterlinkAirlines
IE	SolomonAirlines
IF	IslasAirways
IG	Meridiana
IH	FalconAir(IH)
II	LSMInternational
IJ	T.A.T
IK	Lankair
IL	FlyIlli
IM	Menajet
IN	MATMacedonianAirlines
IO	IndonesianAirlines
IP	IslandSpirit
IQ	AugsburgAirways
IR	IranAir
IS	IslandAirlines
IT	KingfisherAirlines
IV	WindJet
IW	WingsAir
IX	AirIndiaExpress
IY	Yemenia
IZ	ArkiaIsraelAirlines
J2	AzerbaijanAirlines
J3	NorthwesternAir
J4	ALAK
J5	AlaskaSeaplaneService
J6	AVCOM
J7	DenimAir
J8	BerjayaAir
J9	JazeeraAirways
JA	B&HAirlines
JB	Helijet
JC	JALExpress
JD	JapanAirSystem
JE	Mango
JF	L.A.B.FlyingService
JH	FujiDreamAirlines
JI	MidwayAirlines
JJ	TAMBrazilianAirlines
JK	Spanair
JL	JapanAirlinesDomestic
JM	AirJamaica
JN	ExcelAirways
JO	JALways
JP	AdriaAirways
JQ	JetstarAirways
JR	JoyAir
JS	AirKoryo
JT	LionMentariAirlines
JU	JatAirways
JV	BearskinLakeAirService
JW	ArrowAir
JX	Jusurairways
JY	Aereonauticamilitare
JZ	SkywaysExpress
K1	Kostromskieavialinii
K2	Eurolot
K4	KalittaAir
K5	SeaPortAirlines
K6	CambodiaAngkorAir(K6)
K7	KoralBlueAirlines
K8	ZambiaSkyways
K9	KryloAirlines
KA	Dragonair
KB	DrukAir
KC	AirAstana
KD	KDAvia
KE	KoreanAir
KF	Blue1
KG	RoyalAirways
KH	KharkivAirlines
KI	AdamAir
KJ	BritishMediterraneanAirways
KK	Atlasjet
KL	KLMRoyalDutchAirlines
KM	AirMalta
KN	ChinaUnited
KO	AlaskaCentralExpress
KP	AirCape
KQ	KenyaAirways
KR	ComoresAirlines
KS	PeninsulaAirways
KT	VickJet
KU	KuwaitAirways
KV	Kavminvodyavia
KW	CarnivalAirLines
KX	CaymanAirways
KY	KSY
KZ	NipponCargoAirlines
L1	AllArgentina
L2	LyndenAirCargo
L3	LTUAustria
L4	LuchshAirlines
L5	Lufttransport
L6	MauritaniaAirlinesInternational
L7	LuganskAirlines
L8	LineBlue
L9	AllAsia
LA	LANAirlines
LB	AirCosta
LC	VarigLog
LD	LineaTuristicaAerotuy
LF	FlyNordic
LG	Luxair
LH	Lufthansa
LI	LeewardIslandsAirTransport
LJ	JinAir
LK	AirLuxor
LL	Allegro
LM	Livingston
LN	LibyanArabAirlines
LO	LOTPolishAirlines
LP	LANPeru
LQ	LCMAIRLINES
LR	LACSA
LS	Jet2.com
LT	LTUInternational
LU	LANExpress
LV	AlbanianAirlines
LW	PacificWings
LX	SwissInternationalAirLines
LY	ElAlIsraelAirlines
LZ	BalkanBulgarianAirlines
M0	AeroMongolia
M1	MarylandAir
M2	MHSAviationGmbH
M3	NorthFlying
M4	MarysyaAirlines
M5	KenmoreAir
M6	AmerijetInternational
M7	TropicalAirways
M8	TransMaldivianAirways
M9	MotorSich
MA	Malév
MB	MNGAirlines
MC	AirMobilityCommand
MD	AirMadagascar
ME	MiddleEastAirlines
MF	XiamenAirlines
MG	ChampionAir
MH	MalaysiaAirlines
MI	SilkAir
MJ	L
MK	AirMauritius
ML	MaldivoAirlines
MM	PeachAviation
MN	Comair
MO	CalmAir
MP	Martinair
MQ	AmericanEagleAirlines
MR	HomerAir
MS	Egyptair
MT	ThomasCookAirlines
MU	ChinaEasternAirlines
MV	ArmenianInternationalAirways
MW	MayaIslandAir
MX	MexicanadeAviaci
MY	MidwestAirlines(Egypt)
MZ	MerpatiNusantaraAirlines
N0	NorteLineasAereas
N1	N1
N2	KaboAir
N3	OmskaviaAirline
N4	RegionaliaMéxico
N5	SkagwayAirService
N6	Aerocontinente(Priv)
N7	AllSpain
N8	NationalAirCargo
N9	AllEurope
NA	Al-NaserAirlines
NB	SterlingAirlines
NC	NorthernAirCargo
NE	SkyEurope
NF	AirVanuatu
NG	LaudaAir
NH	AllNipponAirways
NI	Portugalia
NJ	NordicGlobalAirlines
NK	SpiritAirlines
NL	ShaheenAirInternational
NM	MountCookAirlines
NN	VIMAirlines
NO	NorthPacificAirlines
NP	NileAir
NQ	AirJapan
NR	JettorAirlines
NS	CaucasusAirlines
NT	BinterCanarias
NU	JapanTransoceanAir
NV	AirCentral
NW	NorthwestAirlines
NX	AirMacau
NY	AirIceland
NZ	AirNewZealand
O1	OrbitAirlinesAzerbaijan
O2	OceanicAirlines
O6	Oceanair
O7	OzjetAirlines
O8	OasisHongKongAirlines
OA	OlympicAirlines
OB	AstrakhanAirlines
OC	Catovair
OD	MalindoAir
OE	WestAirAirlines
OF	TransportsetTravauxA
OG	AirOnix
OH	Comair
OI	OrchidAirlines
OJ	OverlandAirways
OK	CzechAirlines
OL	OstfriesischeLufttransport
OM	MIATMongolianAirlines
ON	OurAirline
OO	SkyWest
OP	Chalk'sOceanAirways
OQ	ChongqingAirlines
OR	Arkefly
OS	AustrianAirlines
OT	AeropelicanAirServices
OU	CroatiaAirlines
OV	EstonianAir
OW	ExecutiveAirlines
OX	OrientThaiAirlines
OY	OmniAirInternational
OZ	OzarkAirLines
P0	ProflightCommuterServices
P4	PatriotAirways
P5	AeroRep
P7	RegionalParaguaya
P8	AirMekong
P9	PeruvianAirlines
PA	ParmissAirlines(IPV)
PC	PegasusAirlines
PD	PorterAirlines
PE	AirEurope
PF	PrimeraAir
PG	BangkokAirways
PH	PolynesianAirlines
PI	SunAir(Fiji)
PJ	AirSaintPierre
PK	PakistanInternationalAirlines
PL	Airstars
PM	TropicAir
PN	WestAirChina
PO	FlyPortugal
PP	AirIndus
PQ	LSMAirlines
PR	PhilippineAirlines
PS	UkraineInternationalAirlines
PT	RedJetAndes
PU	PLUNA
PV	PANAir
PW	PrecisionAir
PX	AirNiugini
PY	SurinamAirways
PZ	TAMMercosur
Q2	Maldivian
Q3	SOCHIAIRCHATER
Q4	MastertopLinhasAereas
Q5	40-MileAir
Q6	AeroCondorPeru
Q8	PacificEastAsiaCargoAirlines
Q9	ArikNiger
QA	Click(Mexicana)
QB	GeorgianNationalAirlines
QC	Camair-co
QD	Dobrolet
QE	CrossairEurope
QF	Qantas
QG	CitilinkIndonesia
QH	Kyrgyzstan
QI	CimberAir
QJ	JetAirways
QK	AirCanadaJazz
QL	AeroLanka
QM	AirMalawi
QN	AirArmenia
QO	OriginPacificAirways
QQ	RenoAir
QR	QatarAirways
QS	TravelService
QT	TAMPA
QU	EastAfrican
QV	LaoAirlines
QW	BlueWings
QX	HorizonAir
QY	RedJetCanada
QZ	IndonesiaAirAsia
R0	RoyalAirlines
R1	RoyalSouthernAirlines.
R2	OrenburgAirlines
R3	AircompanyYakutia
R4	Rossiya
R5	MaltaAirCharter
R6	RACSA
R7	AsercaAirlines
R8	AirRussia
R9	CamaiAir
RA	RoyalNepalAirlines
RB	SyrianArabAirlines
RC	AtlanticAirways
RD	RyanInternationalAirlines
RE	AerArann
RF	FloridaWestInternationalAirways
RG	VRGLinhasAereas
RH	RepublicExpressAirlines
RI	MandalaAirlines
RJ	RoyalJordanian
RK	RoyalKhmerAirlines
RL	RoyalFalcon
RM	RainbowAirUS
RN	RainbowAir(RAI)
RO	Tarom
RP	ChautauquaAirlines
RQ	KamAir
RR	RedJetAmerica
RS	SkyRegional
RU	RainbowAirEuro
RV	CaspianAirlines
RW	RepublicAirlines
RX	RainbowAirPolynesia
RY	RainbowAirCanada
RZ	EuroExecExpress
S0	SpikeAirlines
S1	SerbianAirlines
S2	AirSahara
S3	SantaBarbaraAirlines
S4	SATAInternational
S5	TrastAero
S6	SalmonAir
S7	S7Airlines
S8	SnowbirdAirlines
S9	StarbowAirlines
SA	SouthAfricanAirways
SB	AirCaledonieInternational
SC	ShandongAirlines
SD	SudanAirways
SE	XLAirwaysFrance
SF	AirCharterInternational
SG	Spicejet
SH	SharpAirlines
SI	SkynetAirlines
SJ	SriwijayaAir
SK	ScandinavianAirlinesSystem
SL	ThaiLionAir
SM	SpiritofManilaAirlines
SN	BrusselsAirlines
SO	Salsad\\\\'Haiti
SP	SATAAirAcores
SQ	SingaporeAirlines
SR	Swissair
SS	Corsairfly
ST	Germania
SU	AeroflotRussianAirlines
SV	SaudiArabianAirlines
SW	AirNamibia
SX	SkyWorkAirlines
SY	SunCountryAirlines
SZ	Salzburgarrows
T0	TACAPeru
T1	TROPICALLINHASAEREAS
T2	ThaiAirCargo
T3	EasternAirways
T4	HellasJet
T5	TurkmenistanAirlines
T6	TransPasAir
T7	TwinJet
T8	TAN
T9	ThaiStarAirlines
TA	GrupoTACA
TB	TrasBrasil
TC	AirTanzania
TD	TulipAir
TE	FlyLal
TF	MalmöAviation
TG	ThaiAirwaysInternational
TH	TransBrasilAirlines
TI	TransHolding
TJ	T.J.Air
TK	TurkishAirlines
TL	TransMediterraneanAirlines
TM	AirMozambique
TN	AirTahitiNui
TO	TransaviaFrance
TP	TAPPortugal
TQ	TexasWings
TR	TigerAirways
TS	AirTransat
TT	TigerAirwaysAustralia
TU	Tunisair
TV	VirginExpress
TW	TwayAirlines
TX	AirCaraïbes
TY	Iberworld
TZ	Scoot
U1	Aviabus
U2	UnitedFeederService
U3	Avies
U4	PMTair
U5	USA3000Airlines
U6	UralAirlines
U7	USAJetAirlines
U8	Armavia
U9	TatarstanAirlines
UA	UnitedAirlines
UB	MyanmaAirways
UD	Hex'Air
UE	TranseuropeanAirlines
UF	UMAirlines
UG	Tuninter
UH	USHelicopterCorporation
UI	EurocypriaAirlines
UJ	AlMasriaUniversalAirlines
UK	TataSiaAirlines
UL	SriLankanAirlines
UM	AirZimbabwe
UN	TransaeroAirlines
UO	HongKongExpressAirways
UP	Bahamasair
UQ	SkyjetAirlines
UR	UTair-Express
US	USAirways
UT	UTairAviation
UU	AirAustral
UX	AirEuropa
UY	CameroonAirlines
UZ	El-BuraqAirTransport
V0	Conviasa
V2	VisionAirlines(V2)
V3	Carpatair
V4	ReemAir
V5	DanubeWings(V5)
V6	VIPEcuador
V7	AirSenegalInternational
V8	ATRANCargoAirlines
V9	Star1Airlines
VA	VirginAustralia
VB	PacificExpress
VC	StrategicAirlines
VD	SwedJetAirways
VE	VolareAirlines
VF	Valuair
VG	VLMAirlines
VH	VirginPacific
VI	Volga-DneprAirlines
VJ	RoyalAirCambodge
VK	VirginNigeriaAirways
VL	AirVIA
VM	ViaggioAir
VN	VietnamAirlines
VO	TyroleanAirways
VP	VASP
VQ	VikingHellas
VR	TACV
VS	VirginAtlanticAirways
VT	AirTahiti
VU	AirIvoire
VV	AerosvitAirlines
VW	Aeromar
VX	VirginAmerica
VY	VuelingAirlines
VZ	MyTravelAirways
W1	WorldExperienceAirline
W2	MaastrichtAirlines
W3	ArikAir
W4	AeroWorld
W5	MahanAir
W6	WizzAir
W7	AustralBrasil
W8	CargojetAirways
W9	EastwindAirlines
WA	WesternAirlines
WB	RwandairExpress
WC	IslenaDeInversiones
WD	AmsterdamAirlines
WE	CenturionAirCargo
WF	Widerøe
WG	Sunwing
WH	ChinaNorthwestAirlines(WH)
WJ	WebJetLinhasA
WK	EdelweissAir
WL	CheapFlyingInternational
WM	WindwardIslandsAirways
WN	SouthwestAirlines
WO	WorldAirways
WP	IslandAir(WP)
WQ	PanAmWorldAirways
WR	RoyalTonganAirlines
WS	WestJet
WU	WizzAirUkraine
WV	SweFly
WW	bmibaby
WX	CityJet
WY	OmanAir
WZ	RedWings
X1	NikAirways
X3	TUIfly
X7	Chitaavia
XA	XAIRUSA
XB	NEXTBrasil
XE	ExpressJet
XF	VladivostokAir
XG	CalimaAviacion
XJ	MesabaAirlines
XK	Corse-Mediterranee
XL	Aerolane
XM	AlitaliaExpress
XN	Xpressair
XO	LTEInternationalAirways
XP	XPTO
XQ	SunExpress
XR	SkywestAustralia
XS	TexasSpirit
XT	AirExel
XV	BVIAirways
XW	SkyExpress
XX	Greenfly
XY	NasAir
XZ	CongoExpress
Y0	YellowAirTaxi
Y1	YellowstoneClubPrivateShuttle
Y4	Volaris
Y5	AsiaWings
Y7	NordStarAirlines
Y8	MarusyaAirways
Y9	KishAir
YC	CielCanadien
YD	Gomelavia
YE	Yellowtail
YH	YangonAirwaysLtd.
YI	TURAvrupaHavaYollarÄ±
YK	CyprusTurkishAirlines
YL	YamalAirlines
YM	MontenegroAirlines
YO	TransHoldingSystem
YP	AeroLloyd(YP)
YQ	PoletAirlines(Priv)
YR	SENICAIRLINES
YS	Régional
YT	YetiAirways
YV	MesaAirlines
YW	AirNostrum
YX	MidwestAirlines
YY	Virginwings
YZ	LSMAIRLINES
Z2	ZestAir
Z3	AvientAviation
Z4	ZoomAirlines
Z6	ZABAIKALAIRLINES
Z7	REDjet
Z8	Amaszonas
Z9	FlightlinkTanzania
ZA	InteraviaAirlines
ZB	MonarchAirlines
ZC	KorongoAirlines
ZE	EastarJet
ZF	AthensAirways
ZG	VivaMacau
ZH	ShenzhenAirlines
ZI	AigleAzur
ZJ	ZambeziAirlines(ZMA)
ZK	GreatLakesAirlines
ZL	RegionalExpress
ZM	ApacheAir
ZN	ZenithInternationalAirline
ZP	ZabaykalskiiAirlines
ZQ	Locair
ZS	SamaAirlines
ZT	TitanAirways
ZU	HeliosAirways
ZV	AirMidwest
ZW	AirWisconsin
ZX	JapanRegio
ZY	AdaAir
ZZ	Zz
\\N	Avilu
МИ	KMV
ЯП	PolarAirlines
\.


--
-- Data for Name: airports; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.airports (airportcode, citycode, countrycode, locationtype, latitude, longitude, timezoneid, utcoffset, names) FROM stdin;
AAL	AAL	DK	Airport	57.0928	9.8492	Europe/Copenhagen	2.0	Aalborg
AAR	AAR	DK	Airport	56.3039	10.6194	Europe/Copenhagen	2.0	Aarhus
ABE	ABE	US	Airport	40.6522	-75.4408	America/New_York	-4.0	Allentown/Bethl
ABJ	ABJ	CI	Airport	5.2614	-3.9264	Africa/Abidjan	0.0	Abidjan
ABK	ABK	ET	Airport	6.7339	44.2553	Africa/Addis_Ababa	3.0	Kabri Dehar
ABQ	ABQ	US	Airport	35.0406	-106.6094	America/Denver	-6.0	Albuquerque International, NM
ABV	ABV	NG	Airport	9.0067	7.2631	Africa/Lagos	1.0	Abuja International
ABZ	ABZ	GB	Airport	57.2042	-2.2003	Europe/London	1.0	Aberdeen
ACA	ACA	MX	Airport	16.7569	-99.7539	America/Mexico_City	-5.0	Acapulco - Alvarez International
ACC	ACC	GH	Airport	5.605277778	-0.166666667	Africa/Accra	0.0	Accra - Kotoka International
ACE	ACE	ES	Airport	28.9456	-13.6053	Atlantic/Canary	1.0	Lanzarote
ACK	ACK	US	Airport	41.2531	-70.0603	America/New_York	-4.0	Nantucket
ACT	ACT	US	Airport	31.6114	-97.2306	America/Chicago	-5.0	Waco Municipal
ACV	ACV	US	Airport	40.9781	-124.1086	America/Los_Angeles	-7.0	Arcata/Eureka
ACY	AIY	US	Airport	39.4575	-74.5772	America/New_York	-4.0	Atlantic City - International
ADA	ADA	TR	Airport	36.9822	35.2803	Europe/Istanbul	3.0	Adana
ADB	IZM	TR	Airport	38.2925	27.1569	Europe/Istanbul	3.0	Izmir - Adnan Menderes
ADD	ADD	ET	Airport	8.9778	38.7994	Africa/Addis_Ababa	3.0	Addis Ababa
ADK	ADK	US	Airport	51.8811	-176.6483	America/Adak	-9.0	Adak Island
ADL	ADL	AU	Airport	-34.945	138.5306	Australia/Adelaide	9.5	Adelaide
ADQ	ADQ	US	Airport	57.75	-152.4939	America/Anchorage	-8.0	Kodiak - Kodiak Airport
ADZ	ADZ	CO	Airport	12.5836	-81.7111	America/Bogota	-5.0	San Andres Island
AEP	BUE	AR	Airport	-34.5589	-58.4164	America/Argentina/Buenos_Aires	-3.0	Buenos Aires - Jorge Newbery
AER	AER	RU	Airport	43.45	39.9567	Europe/Moscow	3.0	Sochi
AES	AES	NO	Airport	62.5603	6.1103	Europe/Oslo	2.0	Alesund
AEX	AEX	US	Airport	31.3275	-92.5497	America/Chicago	-5.0	Alexandria Louisiana
AGA	AGA	MA	Airport	30.325	-9.4131	Africa/Casablanca	1.0	Agadir
AGH	AGH	SE	Airport	56.2961	12.8472	Europe/Stockholm	2.0	Helsingborg - Angelholm
AGP	AGP	ES	Airport	36.675	-4.4992	Europe/Madrid	2.0	Malaga
AGS	AUG	US	Airport	33.37	-81.9644	America/New_York	-4.0	Augusta, Georgia
AGT	AGT	PY	Airport	-25.4556	-54.8436	America/Asuncion	-4.0	Ciudad del Este - Alejo Garcia
AGU	AGU	MX	Airport	21.7056	-102.3178	America/Mexico_City	-5.0	Aguascalientes
AHB	AHB	SA	Airport	18.2403	42.6567	Asia/Riyadh	3.0	Abha
AHO	AHO	IT	Airport	40.6303	8.2897	Europe/Rome	2.0	Alghero
AIA	AIA	US	Airport	42.0519	-102.8078	America/Denver	-6.0	Alliance
AJA	AJA	FR	Airport	41.9239	8.8025	Europe/Paris	2.0	Ajaccio
AJI	AJI	TR	Airport	39.6539	43.0264	Europe/Istanbul	3.0	AGRI
AJL	AJL	IN	Airport	23.8389	92.6203	Asia/Kolkata	5.5	Aizawl
AJR	AJR	SE	Airport	65.5903	19.2819	Europe/Stockholm	2.0	ARVIDSJAUR
AJU	AJU	BR	Airport	-10.9839	-37.0703	America/Belem	-3.0	Aracaju
AKJ	AKJ	JP	Airport	43.6708	142.4475	Asia/Tokyo	9.0	Asahikawa
AKL	AKL	NZ	Airport	-37.0097	174.7917	Pacific/Auckland	12.0	Auckland - International
ALA	ALA	KZ	Airport	43.3533	77.0422	Asia/Qyzylorda	5.0	Almaty
ALB	ALB	US	Airport	42.7483	-73.8017	America/New_York	-4.0	Albany, NY
ALC	ALC	ES	Airport	38.2822	-0.5581	Europe/Madrid	2.0	Alicante
ALF	ALF	NO	Airport	69.9761	23.3717	Europe/Oslo	2.0	Alta
ALG	ALG	DZ	Airport	36.6942	3.2147	Africa/Algiers	1.0	Algiers
ALS	ALS	US	Airport	37.4375	-105.8664	America/Denver	-6.0	Alamosa
ALW	ALW	US	Airport	46.095	-118.2878	America/Los_Angeles	-7.0	Walla Walla
AMA	AMA	US	Airport	35.2194	-101.7058	America/Chicago	-5.0	Amarillo - International
AMD	AMD	IN	Airport	23.0772	72.6347	Asia/Kolkata	5.5	Ahmedabad
AMH	AMH	ET	Airport	6.0394	37.5906	Africa/Addis_Ababa	3.0	Arba Minch
AMI	AMI	ID	Airport	-8.5608	116.0947	Asia/Makassar	8.0	Mataram
AMM	AMM	JO	Airport	31.7225	35.9933	Asia/Amman	3.0	Amman - Queen Alia International
AMS	AMS	NL	Airport	52.3081	4.7642	Europe/Amsterdam	2.0	Amsterdam - Schiphol
ANC	ANC	US	Airport	61.1744	-149.9964	America/Anchorage	-8.0	Anchorage - International
ANF	ANF	CL	Airport	-23.4444	-70.445	America/Santiago	-4.0	Antofagasta
ANU	ANU	AG	Airport	17.1367	-61.7928	America/Antigua	-4.0	Antigua - V.C. Bird International
AOI	AOI	IT	Airport	43.6167	13.3603	Europe/Rome	2.0	Ancona
AOJ	AOJ	JP	Airport	40.7347	140.6908	Asia/Tokyo	9.0	AOMORICA
AOK	AOK	GR	Airport	35.4214	27.1461	Europe/Athens	3.0	Karpathos
AOR	AOR	MY	Airport	6.1944	100.4008	Asia/Kuala_Lumpur	8.0	Alor Setar
APL	APL	MZ	Airport	-15.1056	39.2817	Africa/Maputo	2.0	Nampula
APW	APW	WS	Airport	-13.8297	-171.9972	Pacific/Apia	13.0	APIA FALEOLO APT
AQJ	AQJ	JO	Airport	29.6117	35.0181	Asia/Amman	3.0	AQABA KING HUSSEIN INTERNATIONAL
AQP	AQP	PE	Airport	-16.3408	-71.5725	America/Lima	-5.0	AREQUIPA RODRIGUEZ BALLON INTL
ARH	ARH	RU	Airport	64.6003	40.7167	Europe/Moscow	3.0	Arkhangelsk
ARI	ARI	CL	Airport	-18.3486	-70.3386	America/Santiago	-4.0	Arica
ARN	STO	SE	Airport	59.6519	17.9186	Europe/Stockholm	2.0	Stockholm
ASB	ASB	TM	Airport	37.9869	58.3608	Asia/Ashgabat	5.0	Ashgabad - S. Turkmenbashy Int'l
ASE	ASE	US	Airport	39.2192	-106.8672	America/Denver	-6.0	Aspen, CO
ASF	ASF	RU	Airport	46.2833	48.0064	Europe/Moscow	3.0	Astrakhan
ASM	ASM	ER	Airport	15.2919	38.9106	Africa/Asmara	3.0	Asmara
ASO	ASO	ET	Airport	10.0186	34.5864	Africa/Addis_Ababa	3.0	Asosa
ASR	ASR	TR	Airport	38.7703	35.4956	Europe/Istanbul	3.0	Kayseri
ASU	ASU	PY	Airport	-25.2397	-57.5192	America/Asuncion	-4.0	Asuncion
ASW	ASW	EG	Airport	23.9644	32.82	Africa/Cairo	2.0	Aswan
ATH	ATH	GR	Airport	37.9364	23.9444	Europe/Athens	3.0	Athens Eleftherios Venizelos
ATL	ATL	US	Airport	33.6367	-84.4281	America/New_York	-4.0	Hartsfield-Jackson Atlanta International Airport GA
ATQ	ATQ	IN	Airport	31.7097	74.7972	Asia/Kolkata	5.5	Amritsar
ATW	ATW	US	Airport	44.2667	-88.5167	America/Chicago	-5.0	Appleton
ATZ	ATZ	EG	Airport	27.0464	31.0119	Africa/Cairo	2.0	ASYUT
AUA	AUA	AW	Airport	12.5014	-70.0153	America/Aruba	-4.0	Aruba
AUH	AUH	AE	Airport	24.43305556	54.64888889	Asia/Dubai	4.0	Abu Dhabi - NADIA International
AUS	AUS	US	Airport	30.1944	-97.67	America/Chicago	-5.0	Austin-Bergstrom International Airport, TX
AUW	AUW	US	Airport	44.9283	-89.6267	America/Chicago	-5.0	Wausau
AVL	AVL	US	Airport	35.4361	-82.5419	America/New_York	-4.0	Asheville
AVP	AVP	US	Airport	41.3386	-75.7233	America/New_York	-4.0	Scranton - Pennsylvania
AWA	AWA	ET	Airport	7.0675	38.4906	Africa/Addis_Ababa	3.0	AWASA
AWZ	AWZ	IR	Airport	31.3375	48.7603	Asia/Tehran	4.5	AHWAZ
AXD	AXD	GR	Airport	40.8558	25.9564	Europe/Athens	3.0	Alexandroupolis
AXM	AXM	CO	Airport	4.4528	-75.7664	America/Bogota	-5.0	Armenia
AXT	AXT	JP	Airport	39.6156	140.2186	Asia/Tokyo	9.0	Akita
AXU	AXU	ET	Airport	14.1467	38.7728	Africa/Addis_Ababa	3.0	Axum
AYT	AYT	TR	Airport	36.8986	30.8006	Europe/Istanbul	3.0	Antalya
AZO	AZO	US	Airport	42.235	-85.5519	America/New_York	-4.0	Kalamazoo/Battle Creek
AZS	AZS	DO	Airport	19.2672	-69.7422	America/Santo_Domingo	-4.0	SAMANA EL CATEY INTL
BAH	BAH	BH	Airport	26.2708	50.6336	Asia/Bahrain	3.0	Bahrain International
BAL	BAL	TR	Airport	37.9289	41.1167	Europe/Istanbul	3.0	Batman
BAQ	BAQ	CO	Airport	10.8897	-74.7808	America/Bogota	-5.0	Barranquilla
BAV	BAV	CN	Airport	40.5606	109.9964	Asia/Shanghai	8.0	Baotou
BBA	BBA	CL	Airport	-45.9161	-71.6894	America/Santiago	-4.0	Balmaceda
BBI	BBI	IN	Airport	20.2444	85.8178	Asia/Kolkata	5.5	Bhubaneshwar
BBK	BBK	BW	Airport	-17.8328	25.1625	Africa/Gaborone	2.0	Kasane
BBO	BBO	SO	Airport	10.3892	44.9411	Africa/Mogadishu	3.0	Berbera
BCN	BCN	ES	Airport	41.2969	2.0783	Europe/Madrid	2.0	Barcelona
BCO	BCO	ET	Airport	5.7839	36.5625	Africa/Addis_Ababa	3.0	JINKA BAKO
BDA	BDA	BM	Airport	32.3642	-64.6786	Atlantic/Bermuda	-3.0	Bermuda - Kindley Field
BDL	HFD	US	Airport	41.9389	-72.6833	America/New_York	-4.0	Hartford - Bradley International, CT
BDO	BDO	ID	Airport	-6.9006	107.5764	Asia/Jakarta	7.0	Bandung
BDQ	BDQ	IN	Airport	22.3361	73.2264	Asia/Kolkata	5.5	Vadodara
BDS	BDS	IT	Airport	40.6606	17.9481	Europe/Rome	2.0	Brindisi
BEG	BEG	RS	Airport	44.8183	20.3092	Europe/Belgrade	2.0	Belgrade
BEL	BEL	BR	Airport	-1.3792	-48.4764	America/Belem	-3.0	Belem
BER	BER	DE	Airport	52.3667	13.5033	Europe/Berlin	2.0	Berlin/Brandenburg
BET	BET	US	Airport	60.7797	-161.8381	America/Anchorage	-8.0	Bethel Municipal
BEW	BEW	MZ	Airport	-19.7964	34.9075	Africa/Maputo	2.0	Beira
BEY	BEY	LB	Airport	33.8208	35.4883	Asia/Beirut	3.0	Beirut Rafik Hariri International
BFF	BFF	US	Airport	41.8742	-103.5956	America/Denver	-6.0	Scottsbluff
BFL	BFL	US	Airport	35.4336	-119.0567	America/Los_Angeles	-7.0	Bakersfield
BFM	MOB	US	Airport	30.6333	-88.0667	America/Chicago	-5.0	Mobile - Aerospace
BFN	BFN	ZA	Airport	-29.0928	26.3025	Africa/Johannesburg	2.0	Bloemfontein
BGA	BGA	CO	Airport	7.1264	-73.1847	America/Bogota	-5.0	Bucaramanga
BGF	BGF	CF	Airport	4.3978	18.52	Africa/Bangui	1.0	Bangui
BGG	BGG	TR	Airport	38.8614	40.5925	Europe/Istanbul	3.0	BINGOL
BGI	BGI	BB	Airport	13.0747	-59.4925	America/Barbados	-4.0	Barbados (Bridgetown) - Adams International
BGO	BGO	NO	Airport	60.2933	5.2181	Europe/Oslo	2.0	Bergen
BGR	BGR	US	Airport	44.8075	-68.8281	America/New_York	-4.0	Bangor International
BGW	BGW	IQ	Airport	33.2625	44.2344	Asia/Baghdad	3.0	Baghdad International
BGY	MIL	IT	Airport	45.6689	9.7003	Europe/Rome	2.0	Milano Orio - Bergamo
BHD	BFS	GB	Airport	54.6181	-5.8725	Europe/London	1.0	Belfast City
BHE	BHE	NZ	Airport	-41.5178	173.8692	Pacific/Auckland	12.0	BLENHEIM
BHI	BHI	AR	Airport	-38.7272	-62.1533	America/Argentina/Buenos_Aires	-3.0	Bahia Blanca
BHM	BHM	US	Airport	33.5631	-86.7536	America/Chicago	-5.0	Birmingham, AL
BHO	BHO	IN	Airport	23.2875	77.3375	Asia/Kolkata	5.5	Bhopal
BHX	BHX	GB	Airport	52.4536	-1.7478	Europe/London	1.0	Birmingham International
BHY	BHY	CN	Airport	21.5394	109.2939	Asia/Shanghai	8.0	Beihai
BIA	BIA	FR	Airport	42.55	9.4847	Europe/Paris	2.0	Bastia
BIL	BIL	US	Airport	45.8078	-108.5428	America/Denver	-6.0	Billings, MT
BIO	BIO	ES	Airport	43.3011	-2.9106	Europe/Madrid	2.0	Bilbao
BIQ	BIQ	FR	Airport	43.4683	-1.5311	Europe/Paris	2.0	Biarritz
BIS	BIS	US	Airport	46.7722	-100.7458	America/Chicago	-5.0	Bismarck
BJL	BJL	GM	Airport	13.3381	-16.6522	Africa/Banjul	0.0	Banjul - Yundum International
BJM	BJM	BI	Airport	-3.3239	29.3186	Africa/Bujumbura	2.0	Bujumbura International
BJR	BJR	ET	Airport	11.6081	37.3217	Africa/Addis_Ababa	3.0	Bahar Dar
BJV	BXN	TR	Airport	37.2506	27.6644	Europe/Istanbul	3.0	Bodrum - Milas Airport
BJX	BJX	MX	Airport	20.9933	-101.4808	America/Mexico_City	-5.0	Leon-Guanajuato - Del Bajio
BKI	BKI	MY	Airport	5.9372	116.0531	Asia/Kuala_Lumpur	8.0	Kota Kinabalu
BKK	BKK	TH	Airport	13.6858	100.7489	Asia/Bangkok	7.0	Bangkok - Suvarnabhumi Int'l
BKO	BKO	ML	Airport	12.5336	-7.95	Africa/Bamako	0.0	Bamako
BLA	BLA	VE	Airport	10.1072	-64.6892	America/Caracas	-4.0	Barcelona
BLL	BLL	DK	Airport	55.7403	9.1517	Europe/Copenhagen	2.0	Billund
BLQ	BLQ	IT	Airport	44.5308	11.2969	Europe/Rome	2.0	Bologna
BLR	BLR	IN	Airport	13.1989	77.7056	Asia/Kolkata	5.5	Bengaluru/Bangalore International
BLZ	BLZ	MW	Airport	-15.6792	34.9739	Africa/Blantyre	2.0	Blantyre
BMA	STO	SE	Airport	59.3544	17.9417	Europe/Stockholm	2.0	STOCKHOLM BROMMA APT
BNA	BNA	US	Airport	36.1244	-86.6783	America/Chicago	-5.0	Nashville, TN
BNE	BNE	AU	Airport	-27.3842	153.1175	Australia/Brisbane	10.0	Brisbane International
BOD	BOD	FR	Airport	44.8286	-0.7153	Europe/Paris	2.0	Bordeaux
BOG	BOG	CO	Airport	4.7017	-74.1469	America/Bogota	-5.0	Bogotá
BOI	BOI	US	Airport	43.5644	-116.2228	America/Denver	-6.0	Boise, ID
BOJ	BOJ	BG	Airport	42.5697	27.5153	Europe/Sofia	3.0	Burgas
BOM	BOM	IN	Airport	19.0886	72.8681	Asia/Kolkata	5.5	Mumbai - Chhatrapati Shivaji Intl. Airport
BOO	BOO	NO	Airport	67.2692	14.3653	Europe/Oslo	2.0	Bodo
BOS	BOS	US	Airport	42.3644	-71.0053	America/New_York	-4.0	Boston - Logan International, MA
BPN	BPN	ID	Airport	-1.2683	116.8944	Asia/Makassar	8.0	Balikpapan
BPS	BPS	BR	Airport	-16.4386	-39.0808	America/Belem	-3.0	Porto Seguro
BPT	BPT	US	Airport	29.9508	-94.0208	America/Chicago	-5.0	Beaumont - Jefferson County
BQH	BQH	GB	Airport	51.3308	0.0322	Europe/London	1.0	London Biggin Hill Apt
BQN	BQN	PR	Airport	18.495	-67.1294	America/Puerto_Rico	-4.0	AGUADILLA RAFAEL HERNANDEZ
BRC	BRC	AR	Airport	-41.1511	-71.1578	America/Argentina/Buenos_Aires	-3.0	San Carlos De Bariloche International
BRE	BRE	DE	Airport	53.0475	8.7867	Europe/Berlin	2.0	Bremen
BRI	BRI	IT	Airport	41.1381	16.765	Europe/Rome	2.0	Bari
BRM	BRM	VE	Airport	10.0428	-69.3586	America/Caracas	-4.0	Barquisimeto
BRN	BRN	CH	Airport	46.9142	7.4972	Europe/Zurich	2.0	Berne - Belp
BRO	BRO	US	Airport	25.9069	-97.4258	America/Chicago	-5.0	Brownsville - S. Padre Island International
BRQ	BRQ	CZ	Airport	49.1514	16.6944	Europe/Prague	2.0	Brno
BRS	BRS	GB	Airport	51.3825	-2.7189	Europe/London	1.0	Bristol
BRU	BRU	BE	Airport	50.9014	4.4844	Europe/Brussels	2.0	Brussels - Airport
BRW	BRW	US	Airport	71.2856	-156.7661	America/Anchorage	-8.0	Barrow Wbas
BSB	BSB	BR	Airport	-15.86055556	-47.91527778	America/Sao_Paulo	-3.0	Brasilia International
BSL	BSL	CH	Airport	47.6011	7.5217	Europe/Paris	2.0	Basel Euroairport
BTR	BTR	US	Airport	30.5331	-91.1497	America/Chicago	-5.0	Baton Rouge - Ryan
BTU	BTU	MY	Airport	3.1242	113.0197	Asia/Kuala_Lumpur	8.0	Bintulu
BTV	BTV	US	Airport	44.4719	-73.1533	America/New_York	-4.0	Burlington, International, VT
BUD	BUD	HU	Airport	47.4369	19.2556	Europe/Budapest	2.0	Budapest, Liszt Ferenc
BUF	BUF	US	Airport	42.9406	-78.7322	America/New_York	-4.0	Buffalo,  Greater Buffalo International, NY
BUQ	BUQ	ZW	Airport	-20.0175	28.6178	Africa/Harare	2.0	Bulawayo
BUR	BUR	US	Airport	34.2006	-118.3586	America/Los_Angeles	-7.0	Burbank
BUS	BUS	GE	Airport	41.6103	41.5997	Asia/Tbilisi	4.0	BATUMI
BVC	BVC	CV	Airport	16.1367	-22.8889	Atlantic/Cape_Verde	-1.0	BOA VISTA ISLAND RABIL
BWI	BWI	US	Airport	39.1753	-76.6683	America/New_York	-4.0	Baltimore - Washington International, DC
BWK	BWK	HR	Airport	43.2858	16.6797	Europe/Zagreb	2.0	BRAC
BWN	BWN	BN	Airport	4.9442	114.9283	Asia/Brunei	8.0	Bandar Seri Begawan - Brunei International
BZE	BZE	BZ	Airport	17.5392	-88.3083	America/Belize	-6.0	Belize City - Goldson International
BZG	BZG	PL	Airport	53.0967	17.9778	Europe/Warsaw	2.0	Bydgoszcz
BZN	BZN	US	Airport	45.7775	-111.1531	America/Denver	-6.0	Bozeman
BZV	BZV	CG	Airport	-4.2517	15.2531	Africa/Brazzaville	1.0	Brazzaville
CAE	CAE	US	Airport	33.9389	-81.1194	America/New_York	-4.0	Columbia, SC
CAG	CAG	IT	Airport	39.2514	9.0578	Europe/Rome	2.0	Cagliari
CAI	CAI	EG	Airport	30.1219	31.4056	Africa/Cairo	2.0	Cairo International
CAK	CAK	US	Airport	40.9161	-81.4422	America/New_York	-4.0	Akron/Canton
CAN	CAN	CN	Airport	23.3925	113.2989	Asia/Shanghai	8.0	Guangzhou Baiyun International
CBR	CBR	AU	Airport	-35.3069	149.195	Australia/Sydney	10.0	Canberra
CCJ	CCJ	IN	Airport	11.1369	75.9553	Asia/Kolkata	5.5	Kozhikode
CCP	CCP	CL	Airport	-36.7728	-73.0631	America/Santiago	-4.0	Concepcion
CCS	CCS	VE	Airport	10.6031	-66.9906	America/Caracas	-4.0	Caracas
CCU	CCU	IN	Airport	22.6547	88.4467	Asia/Kolkata	5.5	Kolkata
CDG	PAR	FR	Airport	49.0097	2.5478	Europe/Paris	2.0	Paris - Charles De Gaulle
CDR	CDR	US	Airport	42.835	-103.0986	America/Denver	-6.0	Chadron
CDV	CDV	US	Airport	60.4917	-145.4775	America/Anchorage	-8.0	Cordova - Mile 13 Field
CEB	CEB	PH	Airport	10.3075	123.9794	Asia/Manila	8.0	Cebu
CEC	CEC	US	Airport	41.7803	-124.2367	America/Los_Angeles	-7.0	Crescent City
CEI	CEI	TH	Airport	19.9522	99.8831	Asia/Bangkok	7.0	Chiang Rai
CEZ	CEZ	US	Airport	37.3031	-108.6286	America/Denver	-6.0	Cortez
CFU	CFU	GR	Airport	39.6019	19.9117	Europe/Athens	3.0	Kerkyra
CGB	CGB	BR	Airport	-15.6531	-56.1167	America/Campo_Grande	-4.0	Cuiaba
CGH	SAO	BR	Airport	-23.6267	-46.6581	America/Sao_Paulo	-3.0	Sao Paulo - Congonhas
CGK	JKT	ID	Airport	-6.1256	106.6558	Asia/Jakarta	7.0	Jakarta - Soekarno-Hatta International
CGN	CGN	DE	Airport	50.8658	7.1428	Europe/Berlin	2.0	Cologne - Cologne/Bonn Airport
CGO	CGO	CN	Airport	34.5194	113.8411	Asia/Shanghai	8.0	Zhengzhou
CGQ	CGQ	CN	Airport	43.9961	125.6853	Asia/Shanghai	8.0	Changchun
CGR	CGR	BR	Airport	-20.4686	-54.6725	America/Campo_Grande	-4.0	Campo Grande International
CHA	CHA	US	Airport	35.0353	-85.2039	America/New_York	-4.0	Chattanooga
CHC	CHC	NZ	Airport	-43.4894	172.5322	Pacific/Auckland	12.0	Christchurch International
CHG	CHG	CN	Airport	41.5414	120.4339	Asia/Urumqi	6.0	CHAOYANG
CHO	CHO	US	Airport	38.1386	-78.4528	America/New_York	-4.0	Charlottesville Albemarie
CHQ	CHQ	GR	Airport	35.5317	24.1497	Europe/Athens	3.0	Chania
CHS	CHS	US	Airport	32.8986	-80.0406	America/New_York	-4.0	Charleston, SC
CIC	CIC	US	Airport	39.7961	-121.8583	America/Los_Angeles	-7.0	Chico
CID	CID	US	Airport	41.8847	-91.7108	America/Chicago	-5.0	Cedar Rapids, IA
CIT	AKX	KZ	Airport	42.3642	69.4789	Asia/Qyzylorda	5.0	Shymkent
CJB	CJB	IN	Airport	11.03	77.0433	Asia/Kolkata	5.5	Coimbatore
CJC	CJC	CL	Airport	-22.4981	-68.9081	America/Santiago	-4.0	Calama
CJU	CJU	KR	Airport	33.5114	126.4931	Asia/Seoul	9.0	Jeju
CKB	CKB	US	Airport	39.2967	-80.2281	America/New_York	-4.0	Clarksburg
CKG	CKG	CN	Airport	29.7194	106.6419	Asia/Shanghai	8.0	Chongqing
CKY	CKY	GN	Airport	9.5769	-13.6119	Africa/Conakry	0.0	Conakry
CLD	CLD	US	Airport	33.1283	-117.28	America/Los_Angeles	-7.0	Carlsbad, CA
CLE	CLE	US	Airport	41.4117	-81.8497	America/New_York	-4.0	Cleveland - Hopkins International, OH
CLJ	CLJ	RO	Airport	46.7853	23.6861	Europe/Bucharest	3.0	Cluj
CLL	CLL	US	Airport	30.5886	-96.3639	America/Chicago	-5.0	College Station - Easterwood Field
CLO	CLO	CO	Airport	3.5433	-76.3817	America/Bogota	-5.0	Cali
CLT	CLT	US	Airport	35.2139	-80.9431	America/New_York	-4.0	Charlotte, NC
CLY	CLY	FR	Airport	42.5203	8.7931	Europe/Paris	2.0	Calvi
CMB	CMB	LK	Airport	7.1803	79.8853	Asia/Colombo	5.5	Colombo - Katunayake
CME	CME	MX	Airport	18.6533	-91.8011	America/Mexico_City	-5.0	Ciudad Del Carmen
CMH	CMH	US	Airport	39.9981	-82.8919	America/New_York	-4.0	Columbus, OH
CMI	CMI	US	Airport	40.0392	-88.2781	America/Chicago	-5.0	Champaign Urbana
CMN	CAS	MA	Airport	33.3675	-7.59	Africa/Casablanca	1.0	Casablanca - Mohamed V
CMX	CMX	US	Airport	47.1683	-88.4892	America/New_York	-4.0	Hancock
CND	CND	RO	Airport	44.3622	28.4883	Europe/Bucharest	3.0	Constanta
CNF	BHZ	BR	Airport	-19.6339	-43.9689	America/Sao_Paulo	-3.0	Belo Horizonte - Tancredo Neves International
CNS	CNS	AU	Airport	-16.8781	145.7489	Australia/Brisbane	10.0	Cairns
CNX	CNX	TH	Airport	18.7714	98.9628	Asia/Bangkok	7.0	Chiang Mai
CNY	CNY	US	Airport	38.7608	-109.7475	America/Denver	-6.0	Moab
COD	COD	US	Airport	44.5178	-109.0261	America/Denver	-6.0	Cody
COK	COK	IN	Airport	10.1519	76.4019	Asia/Kolkata	5.5	Kochi
COO	COO	BJ	Airport	6.3572	2.3844	Africa/Porto-Novo	1.0	Cotonou
COR	COR	AR	Airport	-31.31	-64.2083	America/Argentina/Buenos_Aires	-3.0	Cordoba
COS	COS	US	Airport	38.8058	-104.7008	America/Denver	-6.0	Colorado Springs - Peterson Field, CO
COU	COU	US	Airport	38.8181	-92.2197	America/Chicago	-5.0	COLUMBIA REGIONAL
CPH	CPH	DK	Airport	55.6203	12.6503	Europe/Copenhagen	2.0	Copenhagen
CPO	CPO	CL	Airport	-27.2617	-70.7792	America/Santiago	-4.0	Copiapo
CPR	CPR	US	Airport	42.9081	-106.4644	America/Denver	-6.0	Casper
CPT	CPT	ZA	Airport	-33.9647	18.6017	Africa/Johannesburg	2.0	Cape Town
CRD	CRD	AR	Airport	-45.7853	-67.4656	America/Argentina/Buenos_Aires	-3.0	Comodoro Rivadavia
CRK	CRK	PH	Airport	15.1861	120.5603	Asia/Manila	8.0	ANGELES/MABALACAT CLARK INTERNATIONAL
CRP	CRP	US	Airport	27.7703	-97.5011	America/Chicago	-5.0	Corpus Christi - International
CRW	CRW	US	Airport	38.3731	-81.5931	America/New_York	-4.0	Charleston, West Virginia - Yeager
CSL	CSL	US	Airport	35.2333	-120.6333	America/Los_Angeles	-7.0	San Luis Obispo
CSX	CSX	CN	Airport	28.1936	113.2178	Asia/Shanghai	8.0	Changsha
CTA	CTA	IT	Airport	37.4667	15.0639	Europe/Rome	2.0	Catania
CTG	CTG	CO	Airport	10.4425	-75.5131	America/Bogota	-5.0	Cartagena
CTS	SPK	JP	Airport	42.79583333	141.6691667	Asia/Tokyo	9.0	Sapporo - Chitose
CTU	CTU	CN	Airport	30.57861111	103.9472222	Asia/Shanghai	8.0	Chengdu
CUC	CUC	CO	Airport	7.9275	-72.5117	America/Bogota	-5.0	Cucuta
CUL	CUL	MX	Airport	24.7644	-107.4747	America/Mazatlan	-6.0	Culiacan
CUM	CUM	VE	Airport	10.4503	-64.1306	America/Caracas	-4.0	Cumana
CUN	CUN	MX	Airport	21.0367	-86.8772	America/Cancun	-5.0	Cancun
CUR	CUR	CW	Airport	12.1889	-68.9597	America/Curacao	-4.0	Curacao - Hato Airport
CUU	CUU	MX	Airport	28.7028	-105.9644	America/Mazatlan	-6.0	Chihuahua
CUZ	CUZ	PE	Airport	-13.5358	-71.9389	America/Lima	-5.0	CUZCO A. VELASCO ASTETE INTL
CVG	CVG	US	Airport	39.0489	-84.6678	America/New_York	-4.0	Cincinnati - Northern Kentucky, OH
CWA	CWA		Airport	44.7833	-89.6667	America/Chicago	-5.0	WAUSAU CENTRAL WISCONSIN APT
CWB	CWB	BR	Airport	-25.5286	-49.1758	America/Sao_Paulo	-3.0	Curitiba
CWL	CWL	GB	Airport	51.3967	-3.3433	Europe/London	1.0	Cardiff
CYS	CYS	US	Airport	41.1558	-104.8119	America/Denver	-6.0	Cheyenne Municipal
CZM	CZM	MX	Airport	20.5217	-86.9369	America/Cancun	-5.0	Cozumel
CZX	CZX	CN	Airport	31.9194	119.7783	Asia/Shanghai	8.0	Changzhou
DAB	DAB	US	Airport	29.18	-81.0581	America/New_York	-4.0	Daytona Beach
DAC	DAC	BD	Airport	23.8433	90.3978	Asia/Dhaka	6.0	Dhaka - Zia International
DAD	DAD	VN	Airport	16.0439	108.1994	Asia/Ho_Chi_Minh	7.0	DA NANG
DAR	DAR	TZ	Airport	-6.8781	39.2025	Africa/Dar_es_Salaam	3.0	Dar es Salaam International
DAT	DAT	CN	Airport	39.7189	113.1461	Asia/Shanghai	8.0	Datong
DAV	DAV		Airport	8.3911	-82.435	America/Panama	-5.0	DAVID ENRIQUE MALEK INTERNATIONAL
DAX	DZU	CN	Airport	31.1319	107.4306	Asia/Shanghai	8.0	Dazhou
DAY	DAY	US	Airport	39.9025	-84.2194	America/New_York	-4.0	Dayton - James Cox International, OH
DBV	DBV	HR	Airport	42.5614	18.2683	Europe/Zagreb	2.0	Dubrovnik
DCA	WAS	US	Airport	38.8522	-77.0378	America/New_York	-4.0	Washington National
DDC	DDC	US	Airport	37.7603	-99.9642	America/Chicago	-5.0	Dodge City
DDG	DDG	CN	Airport	40.0256	124.2869	Asia/Shanghai	8.0	Dandong
DEB	DEB	HU	Airport	47.4889	21.6153	Europe/Budapest	2.0	Debrecen
DEL	DEL	IN	Airport	28.5664	77.1031	Asia/Kolkata	5.5	New Delhi - Indira Gandhi International
DEN	DEN	US	Airport	39.8617	-104.6731	America/Denver	-6.0	Denver - International, CO
DFW	DFW	US	Airport	32.8969	-97.0381	America/Chicago	-5.0	Dallas/Fort Worth - International, TX
DGO	DGO	MX	Airport	24.1242	-104.5281	America/Mexico_City	-5.0	Durango
DIB	DIB	IN	Airport	27.4833	95.0167	Asia/Kolkata	5.5	Dibrugarh
DIK	DIK	US	Airport	46.8	-102.8	America/Denver	-6.0	Dickinson
DIR	DIR	ET	Airport	9.6247	41.8542	Africa/Addis_Ababa	3.0	Dire Dawa
DIY	DIY	TR	Airport	37.8939	40.2011	Europe/Istanbul	3.0	DIYARBAKIR
DJE	DJE	TN	Airport	33.875	10.7756	Africa/Tunis	1.0	Djerba
DKR	DKR	SN	Airport	14.7425	-17.4933	Africa/Dakar	0.0	Dakar
DLA	DLA	CM	Airport	4.0061	9.7194	Africa/Douala	1.0	Douala
DLC	DLC	CN	Airport	38.9656	121.5386	Asia/Shanghai	8.0	Dalian
DLH	DLH	US	Airport	46.8422	-92.1936	America/Chicago	-5.0	Duluth/Superior - Duluth International
DLM	DLM	TR	Airport	36.7131	28.7925	Europe/Istanbul	3.0	Dalaman
DME	MOW	RU	Airport	55.4089	37.9064	Europe/Moscow	3.0	Moscow - Domodedovo
DMK	BKK	TH	Airport	13.9125	100.6067	Asia/Bangkok	7.0	Bangkok - Don Muang
DMM	DMM	SA	Airport	26.4711	49.7978	Asia/Riyadh	3.0	Dammam
DMU	DMU	IN	Airport	25.8825	93.7744	Asia/Kolkata	5.5	Dimapur
DNH	DNH	CN	Airport	40.0922	94.6817	Asia/Urumqi	6.0	DUNHUANG
DNK	DNK	UA	Airport	48.3572	35.1006	Europe/Kiev	3.0	Dnipropetrovsk-42
DNZ	DNZ	TR	Airport	37.7856	29.7014	Europe/Istanbul	3.0	Denizli
DOH	DOH	QA	Airport	25.2744	51.6083	Asia/Qatar	3.0	Doha
DOK	DOK	UA	Airport	48.0736	37.7397	Europe/Kiev	3.0	Donetsk
DPS	DPS	ID	Airport	-8.7481	115.1672	Asia/Makassar	8.0	Denpasar-Bali
DQA	DQA	CN	Airport	46.75	125.1392	Asia/Urumqi	6.0	DAQING SARTU
DRO	DRO	US	Airport	37.1522	-107.7536	America/Denver	-6.0	Durango La Plata
DRS	DRS	DE	Airport	51.1344	13.7681	Europe/Berlin	2.0	Dresden
DRT	DRT	US	Airport	29.3733	-100.9264	America/Chicago	-5.0	Del Rio International
DRW	DRW	AU	Airport	-12.4147	130.8767	Australia/Darwin	9.5	Darwin
DSE	DSE	ET	Airport	11.0833	39.7167	Africa/Addis_Ababa	3.0	Dessie
DSM	DSM	US	Airport	41.5342	-93.6578	America/Chicago	-5.0	Des Moines, IA
DSN	DSN	CN	Airport	39.4922	109.8631	Asia/Shanghai	8.0	Ordos
DSS	DKR	SN	Airport	14.6725	-17.0714	Africa/Dakar	0.0	DAKAR BLAISE DIAGNE INTERNATIONAL
DTM	DTM	DE	Airport	51.5183	7.6122	Europe/Berlin	2.0	Dortmund
DTN	SHV	US	Airport	0	0	America/Chicago	-5.0	Shreveport Downtown
DTW	DTT	US	Airport	42.2125	-83.3533	America/New_York	-4.0	Detroit - Wayne County, MI
DTZ	DTM	DE	RailwayStation	51.5178	7.4592	Europe/Berlin	2.0	DORTMUND HBF RAIL STATION
DUB	DUB	IE	Airport	53.4214	-6.27	Europe/Dublin	1.0	Dublin
DUD	DUD	NZ	Airport	-45.9292	170.1975	Pacific/Auckland	12.0	DUNEDIN
DUR	DUR	ZA	Airport	-29.6144	31.1164	Africa/Johannesburg	2.0	Durban International Airport
DUS	DUS	DE	Airport	51.2894	6.7667	Europe/Berlin	2.0	Dusseldorf - Nordrhein-Westfalen
DVL	DVL	US	Airport	48.1156	-98.9081	America/Chicago	-5.0	Devils Lake
DVO	DVO	PH	Airport	7.1253	125.6456	Asia/Manila	8.0	Davao
DXB	DXB	AE	Airport	25.2528	55.3644	Asia/Dubai	4.0	Dubai
DYG	DYG	CN	Airport	29.1044	110.4431	Asia/Shanghai	8.0	Dayong
DYU	DYU	TJ	Airport	38.5433	68.825	Asia/Dushanbe	5.0	DUSHANBE INTERNATIONAL
EAR	EAR	US	Airport	40.7267	-99.0092	America/Chicago	-5.0	Kearney
EAT	EAT	US	Airport	47.3989	-120.2072	America/Los_Angeles	-7.0	Wenatchee
EAU	EAU	US	Airport	44.8658	-91.4842	America/Chicago	-5.0	Eau Clair
EBB	EBB	UG	Airport	0.0425	32.4436	Africa/Kampala	3.0	Entebbe
EBJ	EBJ	DK	Airport	55.52638889	8.5525	Europe/Copenhagen	2.0	Esbjerg
EBL	EBL	IQ	Airport	36.2378	43.9631	Asia/Baghdad	3.0	Erbil
ECN	ECN		Airport	35.1597	33.4883	Asia/Nicosia	3.0	ERCAN
ECP	ECP	US	Airport	30.3578	-85.7989	America/Chicago	-5.0	PANAMA CITY NW FLORIDA BEACHES INTL
EDI	EDI	GB	Airport	55.95	-3.3725	Europe/London	1.0	Edinburgh
EDO	EDO	TR	Airport	39.5547	27.0139	Europe/Istanbul	3.0	EDREMIT KORFEZ
EFL	EFL	GR	Airport	38.12	20.5006	Europe/Athens	3.0	Kefallinia
EGE	EGE	US	Airport	39.6425	-106.9178	America/Denver	-6.0	Vail/Eagle County, CO
EGO	EGO	RU	Airport	50.6439	36.59	Europe/Moscow	3.0	Belgorod
EJA	EJA	CO	Airport	7.0244	-73.8067	America/Bogota	-5.0	BARRANCABERMEJA YARIGUIES
ELM	ELM	US	Airport	42.16	-76.8917	America/New_York	-4.0	Elmira/Corning
ELP	ELP	US	Airport	31.8025	-106.3983	America/Denver	-6.0	El Paso International, TX
ELS	ELS	ZA	Airport	-33.0356	27.8258	Africa/Johannesburg	2.0	East London
EMA	EMA	GB	Airport	52.8311	-1.3281	Europe/London	1.0	East Midlands
ENU	ENU	NG	Airport	6.4742	7.5619	Africa/Lagos	1.0	ENUGU AKANU IBIAM INTL
ERC	ERC	TR	Airport	39.7103	39.5269	Europe/Istanbul	3.0	Erzincan
ERI	ERI	US	Airport	42.0819	-80.1761	America/New_York	-4.0	Erie International
ERZ	ERZ	TR	Airport	39.9564	41.1703	Europe/Istanbul	3.0	Erzurum
ESB	ANK	TR	Airport	40.1281	32.995	Europe/Istanbul	3.0	Ankara - Esenboga
EUG	EUG	US	Airport	44.1247	-123.2119	America/Los_Angeles	-7.0	Eugene, OR
EVE	EVE	NO	Airport	68.4914	16.6781	Europe/Oslo	2.0	Harstad-Narvik, Evenes
EVN	EVN	AM	Airport	40.1472	44.3958	Asia/Yerevan	4.0	Yerevan - Zvartnots Int´l
EVV	EVV	US	Airport	38.0369	-87.5325	America/Chicago	-5.0	EVANSVILLE REGIONAL
EWN	EWN	US	Airport	35.0731	-77.0431	America/New_York	-4.0	New Bern
EWR	NYC	US	Airport	40.6925	-74.1686	America/New_York	-4.0	New York - Newark International, NJ
EYW	EYW	US	Airport	24.5561	-81.7594	America/New_York	-4.0	Key West International
EZE	BUE	AR	Airport	-34.8222	-58.5358	America/Argentina/Buenos_Aires	-3.0	Buenos Aires - Ministro Pistarini
EZS	EZS	TR	Airport	38.6069	39.2914	Europe/Istanbul	3.0	Elazig
FAE	FAE	FO	Airport	62.0664	-7.2931	Atlantic/Faroe	1.0	Faroe Islands
FAI	FAI	US	Airport	64.815	-147.8564	America/Anchorage	-8.0	FAIRBANKS INTERNATIONAL APT
FAO	FAO	PT	Airport	37.0144	-7.9658	Europe/Lisbon	1.0	Faro
FAR	FAR	US	Airport	46.9206	-96.8158	America/Chicago	-5.0	Fargo, ND
FAT	FAT	US	Airport	36.7761	-119.7181	America/Los_Angeles	-7.0	Fresno - Air Terminal, CA
FAY	FAY	US	Airport	34.99	-78.8831	America/New_York	-4.0	Fayetteville, North Carolina - Municipal
FBM	FBM	CD	Airport	-11.5914	27.5308	Africa/Lubumbashi	2.0	Lubumbashi
FCA	FCA	US	Airport	48.3106	-114.2561	America/Denver	-6.0	Kalispell
FCO	ROM	IT	Airport	41.8003	12.2389	Europe/Rome	2.0	Rome - Leonardo Da Vinci
FDH	FDH	DE	Airport	47.6714	9.5114	Europe/Berlin	2.0	Friedrichshafen
FEZ	FEZ	MA	Airport	33.9272	-4.9781	Africa/Casablanca	1.0	FES SAISS
FIH	FIH	CD	Airport	-4.3858	15.4444	Africa/Kinshasa	1.0	Kinshasa N'Djili
FKB	FKB	DE	Airport	48.7794	8.0806	Europe/Berlin	2.0	Karlsruhe
FKS	FKS	JP	Airport	37.2275	140.4306	Asia/Tokyo	9.0	Fukushima
FLG	GCN	US	Airport	35.1383	-111.6711	America/Phoenix	-7.0	GRAND CANYON FLAGSTAFF PULLIAM
FLL	FLL	US	Airport	26.0725	-80.1528	America/New_York	-4.0	Fort Lauderdale - International, FL
FLN	FLN	BR	Airport	-27.6706	-48.5472	America/Sao_Paulo	-3.0	Florianopolis
FLO	FLO	US	Airport	34.1875	-79.7247	America/New_York	-4.0	Florence
FLR	FLR	IT	Airport	43.8086	11.2028	Europe/Rome	2.0	Florence - Amerigo Vespucci
FMM	FMM	DE	Airport	47.9881	10.2375	Europe/Berlin	2.0	Memmingen
FMN	FMN	US	Airport	36.7414	-108.2311	America/Denver	-6.0	Farmington, New Mexico - Municipal
FMO	FMO	DE	Airport	52.1347	7.6847	Europe/Berlin	2.0	Munster
FMY	FMY	US	Airport	26.5833	-81.8667	America/New_York	-4.0	Fort Myers - Page Field
FNA	FNA	SL	Airport	8.6164	-13.1956	Africa/Freetown	0.0	Freetown - Lungi International
FNC	FNC	PT	Airport	32.6942	-16.7781	Europe/Lisbon	1.0	Funchal
FNJ	FNJ	KP	Airport	39.2236	125.67	Asia/Pyongyang	9.0	PYONGYANG SUNAN INTL
FNT	FNT	US	Airport	42.9656	-83.7436	America/New_York	-4.0	Flint
FOC	FOC	CN	Airport	25.935	119.6633	Asia/Shanghai	8.0	Fuzhou
FOE	TOP	US	Airport	38.9508	-95.6636	America/Chicago	-5.0	Topeka - Forbes AFB
FOR	FOR	BR	Airport	-3.7764	-38.5325	America/Belem	-3.0	Fortaleza
FRA	FRA	DE	Airport	50.0331	8.5706	Europe/Berlin	2.0	Frankfurt/Main International
FRS	FRS	GT	Airport	16.9156	-89.8697	America/Guatemala	-6.0	Flores
FRU	FRU	KG	Airport	43.0614	74.4775	Asia/Bishkek	6.0	BISHKEK MANAS INTERNATIONAL
FRW	FRW	BW	Airport	-21.1597	27.4744	Africa/Gaborone	2.0	Francistown
FSC	FSC	FR	Airport	41.5022	9.0967	Europe/Paris	2.0	Figari
FSD	FSD	US	Airport	43.5819	-96.7419	America/Chicago	-5.0	Sioux Falls
FSZ	FSZ	JP	Airport	34.7969	138.1808	Asia/Tokyo	9.0	Shizuoka
FTE	FTE	AR	Airport	-50.28	-72.0533	America/Argentina/Buenos_Aires	-3.0	El Calafate
FUE	FUE	ES	Airport	28.4528	-13.8639	Atlantic/Canary	1.0	Fuerteventura
FUJ	FUJ	JP	Airport	32.6664	128.8328	Asia/Tokyo	9.0	GOTO-FUKUE
FUK	FUK	JP	Airport	33.5858	130.4506	Asia/Tokyo	9.0	Fukuoka
FWA	FWA	US	Airport	40.9831	-85.1897	America/Indiana/Indianapolis	-4.0	Fort Wayne Municipal - Baer Field, IN
FYV	FYV	US	Airport	36	-94.1667	America/Chicago	-5.0	Fayetteville, Arkansas - Drake Field Municipal
GAU	GAU	IN	Airport	26.1061	91.5858	Asia/Kolkata	5.5	Guwahati
GAY	GAY	IN	Airport	24.7444	84.9511	Asia/Kolkata	5.5	Gaya
GBE	GBE	BW	Airport	-24.5553	25.9183	Africa/Gaborone	2.0	Gaborone - Sir Seretse Khama International
GCC	GCC	US	Airport	44.3475	-105.5417	America/Denver	-6.0	Gillette
GCI	GCI	GB	Airport	49.4347	-2.6019	Europe/London	1.0	Guernsey
GCK	GCK	US	Airport	37.9275	-100.7244	America/Chicago	-5.0	Garden City Municipal
GCM	GCM	KY	Airport	19.2928	-81.3578	America/Cayman	-5.0	GRAND CAYMAN OWEN ROBERTS INTL
GDE	GDE	ET	Airport	5.935	43.5786	Africa/Addis_Ababa	3.0	Gode
GDL	GDL	MX	Airport	20.5217	-103.3111	America/Mexico_City	-5.0	Guadalajara
GDN	GDN	PL	Airport	54.3775	18.4661	Europe/Warsaw	2.0	Gdansk
GDQ	GDQ	ET	Airport	12.52	37.4342	Africa/Addis_Ababa	3.0	Gonder
GEG	GEG	US	Airport	47.6172	-117.54	America/Los_Angeles	-7.0	Spokane International, WA
GEO	GEO	GY	Airport	6.4986	-58.2542	America/Guyana	-4.0	GEORGETOWN CHEDDI JAGAN INTERNATIONAL
GIG	RIO	BR	Airport	-22.8125	-43.2483	America/Sao_Paulo	-3.0	Rio de Janeiro - International
GIS	GIS	NZ	Airport	-38.6639	177.9769	Pacific/Auckland	12.0	GISBORNE
GJT	GJT	US	Airport	39.1233	-108.5258	America/Denver	-6.0	Grand Junction, CO
GLA	GLA	GB	Airport	55.8719	-4.4333	Europe/London	1.0	Glasgow
GMB	GMB	ET	Airport	8.1289	34.5631	Africa/Addis_Ababa	3.0	Gambela
GMP	SEL	KR	Airport	37.5583	126.7906	Asia/Seoul	9.0	Seoul - Gimpo International
GND	GND	GD	Airport	12.0042	-61.7861	America/Grenada	-4.0	GRENADA MAURICE BISHOP INTL
GNV	GNV	US	Airport	29.69	-82.2717	America/New_York	-4.0	Gainesville, Florida - Allison Municipal
GNY	SFQ	TR	Airport	37.0944	38.8469	Europe/Istanbul	3.0	Sanliurfa - Guney Anadolu
GOA	GOA	IT	Airport	44.4133	8.8375	Europe/Rome	2.0	Genoa
GOB	GOB	ET	Airport	7.1189	40.045	Africa/Addis_Ababa	3.0	Goba
GOI	GOI	IN	Airport	15.3808	73.8314	Asia/Kolkata	5.5	Goa
GOJ	GOJ	RU	Airport	56.23	43.7842	Europe/Moscow	3.0	Nizhny Novgorod
GOM	GOM	CG	Airport	-1.6708	29.2383	Africa/Lubumbashi	2.0	Goma International
GOT	GOT	SE	Airport	57.6628	12.2797	Europe/Stockholm	2.0	Gothenburg - Landvetter
GPA	GPA	GR	Airport	38.1511	21.4256	Europe/Athens	3.0	Patrai
GPS	GPS	EC	Airport	-0.4539	-90.2658	Pacific/Galapagos	-6.0	BALTRA ISLAND SEYMOUR
GPT	GPT	US	Airport	30.4072	-89.07	America/Chicago	-5.0	Gulfport
GRB	GRB	US	Airport	44.4856	-88.1339	America/Chicago	-5.0	Green Bay
GRI	GRI	US	Airport	40.9675	-98.3097	America/Chicago	-5.0	Grand Island
GRJ	GRJ	ZA	Airport	-34.0056	22.3789	Africa/Johannesburg	2.0	George
GRO	GRO	ES	Airport	41.9008	2.7606	Europe/Madrid	2.0	GIRONA COSTA BRAVA APT
GRQ	GRQ	NL	Airport	53.125	6.5833	Europe/Amsterdam	2.0	GRONINGEN EELDE
GRR	GRR	US	Airport	42.8808	-85.5228	America/New_York	-4.0	Grand Rapids, Kent County Intl, MI
GRU	SAO	BR	Airport	-23.4319	-46.4694	America/Sao_Paulo	-3.0	Sao Paulo - Guarulhos International
GRZ	GRZ	AT	Airport	46.9936	15.44	Europe/Vienna	2.0	Graz - Thalerhof
GSO	GSO	US	Airport	36.0978	-79.9372	America/New_York	-4.0	Greensboro - Piedmont Triad International, NC
GSP	GSP	US	Airport	34.8956	-82.2189	America/New_York	-4.0	Greenville - Spartanbur, SC
GTF	GTF	US	Airport	47.4819	-111.3706	America/Denver	-6.0	Great Falls International
GUA	GUA	GT	Airport	14.5844	-90.5272	America/Guatemala	-6.0	Guatemala City
GUC	GUC	US	Airport	38.5356	-106.9331	America/Denver	-6.0	Gunnison
GUM	GUM	GU	Airport	13.4833	144.7961	Pacific/Guam	10.0	Guam - Agana Field
GUW	AKX	KZ	Airport	47.1219	51.8214	Asia/Oral	5.0	Atyrau
GVA	GVA	CH	Airport	46.2381	6.1089	Europe/Zurich	2.0	Genève - Geneva-Cointrin Airport
GWL	GWL	IN	Airport	26.2933	78.2278	Asia/Kolkata	5.5	Gwalior
GWT	GWT	DE	Airport	54.9133	8.3406	Europe/Berlin	2.0	Westerland/Sylt
GYD	BAK	AZ	Airport	40.4675	50.0467	Asia/Baku	4.0	Baku - Heydar Aliyev Int´l
GYE	GYE	EC	Airport	-2.1575	-79.8836	America/Guayaquil	-5.0	Guayaquil
GYN	GYN	BR	Airport	-16.6319	-49.2206	America/Sao_Paulo	-3.0	Goiania
GZP	GZP	TR	Airport	36.2981	32.2903	Europe/Istanbul	3.0	Gazipasa
GZT	GZT	TR	Airport	36.9472	37.4786	Europe/Istanbul	3.0	Gaziantep
HAC	HAC	JP	Airport	33.115	139.7858	Asia/Tokyo	9.0	Hachijo Jima
HAH	YVA	KM	Airport	-11.5336	43.2719	Indian/Comoro	3.0	MORONI PRINCE SAID IBRAHIM
HAJ	HAJ	DE	Airport	52.4606	9.6894	Europe/Berlin	2.0	Hannover
HAK	HAK	CN	Airport	19.9347	110.4589	Asia/Shanghai	8.0	Haikou
HAM	HAM	DE	Airport	53.6303	9.9883	Europe/Berlin	2.0	Hamburg
HAN	HAN	VN	Airport	21.2211	105.8072	Asia/Ho_Chi_Minh	7.0	Hanoi
HAR	HAR	US	Airport	40.2667	-76.8667	America/New_York	-4.0	Harrisburg, Pennsylvania - Skyport
HAU	HAU	NO	Airport	59.3453	5.2083	Europe/Oslo	2.0	Haugesund
HAV	HAV	CU	Airport	22.9903	-82.4078	America/Havana	-4.0	Havanna
HBA	HBA	AU	Airport	-42.8361	147.5103	Australia/Hobart	10.0	Hobart
HBE	ALY	EG	Airport	30.9178	29.6964	Africa/Cairo	2.0	Alexandria - Borg El Arab
HDB	HDB	DE	Airport	49.3933	8.6519	Europe/Berlin	2.0	Heidelberg
HDF	HDF	DE	Airport	53.8786	14.1522	Europe/Berlin	2.0	Heringsdorf/Usedom
HDN	AXG	US	Airport	40.4833	-107.2236	America/Denver	-6.0	Hayden - Yampa Valley, Colorado
HDS	HDS	ZA	Airport	-24.3486	30.9469	Africa/Johannesburg	2.0	Hoedspruit
HDY	HDY	TH	Airport	6.9328	100.395	Asia/Bangkok	7.0	Hat Yai
HEL	HEL	FI	Airport	60.3172	24.9633	Europe/Helsinki	3.0	Helsinki - Vantaa
HER	HER	GR	Airport	35.3397	25.1803	Europe/Athens	3.0	Heraklion
HET	HET	CN	Airport	40.8514	111.8242	Asia/Shanghai	8.0	Hohhot
HFE	HFE	CN	Airport	31.9911	116.9892	Asia/Shanghai	8.0	Hefei
HGA	HGA	SO	Airport	9.5139	44.0839	Africa/Mogadishu	3.0	HARGEISA EGAL INTL
HGH	HGH	CN	Airport	30.2294	120.4344	Asia/Shanghai	8.0	Hangzhou
HHH	HHH	US	Airport	32.2222	-80.6989	America/New_York	-4.0	Hilton Head
HIJ	HIJ	JP	Airport	34.4361	132.9194	Asia/Tokyo	9.0	Hiroshima International
HIL	HIL	ET	Airport	6.0833	44.8	Africa/Addis_Ababa	3.0	Shilabo
HIN	HIN	KR	Airport	35.0886	128.0703	Asia/Seoul	9.0	Jinju
HKD	HKD	JP	Airport	41.77	140.8219	Asia/Tokyo	9.0	Hakodate
HKG	HKG	HK	Airport	22.3089	113.9147	Asia/Hong_Kong	8.0	Hong Kong International Airport
HKT	HKT	TH	Airport	8.1122	98.3053	Asia/Bangkok	7.0	Phuket
HLD	HLD	CN	Airport	49.2086	119.8167	Asia/Shanghai	8.0	Hailar
HLH	HLH	CN	Airport	46.1947	122.0083	Asia/Shanghai	8.0	Ulanhot
HLN	HLN	US	Airport	46.6069	-111.9828	America/Denver	-6.0	Helena, Montana
HMO	HMO	MX	Airport	29.0958	-111.0478	America/Hermosillo	-7.0	Hermosillo
HND	TYO	JP	Airport	35.5522	139.7797	Asia/Tokyo	9.0	Tokyo - Haneda
HNL	HNL	US	Airport	21.3278	-157.9222	Pacific/Honolulu	-10.0	Honolulu International
HOG	HOG	CU	Airport	20.7856	-76.315	America/Havana	-4.0	Holguin
HOV	HOV	NO	Airport	62.1792	6.0711	Europe/Oslo	2.0	Orsta-Volda
HPN	HPN	US	Airport	41.0669	-73.7075	America/New_York	-4.0	Westchester County
HRB	HRB	CN	Airport	45.6233	126.2503	Asia/Shanghai	8.0	Harbin
HRE	HRE	ZW	Airport	-17.9319	31.0928	Africa/Harare	2.0	Harare
HRG	HRG	EG	Airport	27.1786	33.8014	Africa/Cairo	2.0	Hurghada
HRK	HRK	UA	Airport	49.9261	36.2836	Europe/Kiev	3.0	Kharkov
HRL	HFD	US	Airport	26.2286	-97.6544	America/Chicago	-5.0	Harlingen, Texas
HSG	HSG	JP	Airport	33.1497	130.3022	Asia/Tokyo	9.0	Saga Airport
HSV	HSV	US	Airport	34.6372	-86.775	America/Chicago	-5.0	Huntsville, Madison County, AL
HTS	HTS	US	Airport	38.3683	-82.5592	America/New_York	-4.0	Huntington
HTY	HTY	TR	Airport	36.3597	36.2847	Europe/Istanbul	3.0	Hatay
HUE	HUE	ET	Airport	13.8333	36.8794	Africa/Addis_Ababa	3.0	Humera
HUX	HUX	MX	Airport	15.7753	-96.2625	America/Mexico_City	-5.0	Huatulco
HYD	HYD	IN	Airport	17.2311	78.4314	Asia/Kolkata	5.5	Hyderabad
HYN	HYN	CN	Airport	28.5653	121.4303	Asia/Shanghai	8.0	Taizhou
HYS	HYS	US	Airport	38.8503	-99.2756	America/Chicago	-5.0	Hays
IAD	WAS	US	Airport	38.9444	-77.4558	America/New_York	-4.0	Washington - Dulles International, DC
IAH	HOU	US	Airport	29.9844	-95.3414	America/Chicago	-5.0	Houston - Intercontinental, TX
IAS	IAS	RO	Airport	47.1786	27.6206	Europe/Bucharest	3.0	Iasi
IBZ	IBZ	ES	Airport	38.8728	1.3731	Europe/Madrid	2.0	Ibiza
ICN	SEL	KR	Airport	37.4692	126.4506	Asia/Seoul	9.0	Seoul - Incheon International Airport
ICT	ICT	US	Airport	37.6528	-97.4331	America/Chicago	-5.0	Wichita - Mid-Continent, KS
IDA	IDA	US	Airport	43.5144	-112.0708	America/Denver	-6.0	IDAHO FALLS REGIONAL
IDR	IDR	IN	Airport	22.7217	75.8011	Asia/Kolkata	5.5	Indore
IEG	IEG	PL	Airport	52.1386	15.7986	Europe/Warsaw	2.0	ZIELONA GORA BABIMOST
IEV	IEV	UA	Airport	50.4017	30.4497	Europe/Kiev	3.0	KIEV ZHULIANY INTL APT
IFN	IFN	IR	Airport	32.7517	51.8697	Asia/Tehran	4.5	ESFAHAN SHAHID BEHESHTI INTL
IGD	IGD	TR	Airport	39.9728	43.8844	Europe/Istanbul	3.0	Igdir
IGR	IGR	AR	Airport	-25.7372	-54.4733	America/Argentina/Buenos_Aires	-3.0	Iguazu
IGU	IGU	BR	Airport	-25.5961	-54.4872	America/Sao_Paulo	-3.0	Foz do Iguaçu - Cataratas
IKA	THR	IR	Airport	35.4161	51.1522	Asia/Tehran	4.5	Tehran - Imam Khomeini Intl
ILE	ILE	US	Airport	31.085	-97.6867	America/Chicago	-5.0	Killeen Municipal
ILM	ILM	US	Airport	34.2706	-77.9025	America/New_York	-4.0	Wilmington
IMF	IMF	IN	Airport	24.76	93.8967	Asia/Kolkata	5.5	Imphal
INC	INC	CN	Airport	38.4933	106.0119	Asia/Shanghai	8.0	Yinchuan
IND	IND	US	Airport	39.7172	-86.2944	America/Indiana/Indianapolis	-4.0	Indianapolis International, IN
INI	INI	RS	Airport	43.3372	21.8536	Europe/Belgrade	2.0	Nis
INN	INN	AT	Airport	47.2603	11.3439	Europe/Vienna	2.0	Innsbruck - Kranebitten
IOA	IOA	GR	Airport	39.6964	20.8225	Europe/Athens	3.0	Ioannina
IOS	IOS	BR	Airport	-14.8158	-39.0333	America/Belem	-3.0	Ilheus
IPL	IPL	US	Airport	32.835	-115.5747	America/Los_Angeles	-7.0	El Centro - Imperial County
IQQ	IQQ	CL	Airport	-20.5353	-70.1814	America/Santiago	-4.0	Iquique
ISB	ISB	PK	Airport	33.6167	73.0992	Asia/Karachi	5.0	Islamabad International
ISE	ISE	TR	Airport	37.8556	30.3683	Europe/Istanbul	3.0	ISPARTA SULEYMAN DEMIREL
ISG	ISG	JP	Airport	24.3964	124.245	Asia/Tokyo	9.0	Ishigaki
ISL	IST	TR	Airport	40.9769	28.815	Europe/Istanbul	3.0	Istanbul
ISN	ISN	US	Airport	48.1792	-103.6433	America/Chicago	-5.0	Williston - Sloulin Field International
IST	IST	TR	Airport	40.9769	28.8147	Europe/Istanbul	3.0	Istanbul
ISU	ISU	IQ	Airport	35.5625	45.3158	Asia/Baghdad	3.0	Sulaymaniyah International
ITH	ITH	US	Airport	42.4911	-76.4608	America/New_York	-4.0	Ithaca
ITM	OSA	JP	Airport	34.7856	135.4383	Asia/Tokyo	9.0	Osaka - Itami
ITO	ITO	US	Airport	19.7214	-155.0483	Pacific/Honolulu	-10.0	Hilo International
IVC	IVC	NZ	Airport	-46.4147	168.3131	Pacific/Auckland	12.0	INVERCARGILL
IVL	IVL	FI	Airport	68.6072	27.4053	Europe/Helsinki	3.0	Ivalo
IWJ	IWJ	JP	Airport	34.6764	131.7903	Asia/Tokyo	9.0	Iwami
IWK	IWK	JP	Airport	34.1353	132.2356	Asia/Tokyo	9.0	Iwakuni
IXA	IXA	IN	Airport	23.8869	91.2406	Asia/Kolkata	5.5	Agartala
IXB	IXB	IN	Airport	26.6811	88.3286	Asia/Kolkata	5.5	Bagdogra
IXC	IXC	IN	Airport	30.6733	76.7886	Asia/Kolkata	5.5	Chandigarh
IXD	IXD	IN	Airport	25.44	81.7339	Asia/Kolkata	5.5	Allahabad
IXE	IXE	IN	Airport	12.9614	74.89	Asia/Kolkata	5.5	Mangalore
IXJ	IXJ	IN	Airport	32.6892	74.8375	Asia/Kolkata	5.5	Jammu
IXL	IXL	IN	Airport	34.1358	77.5464	Asia/Kolkata	5.5	Leh
IXM	IXM	IN	Airport	9.8344	78.0933	Asia/Kolkata	5.5	Madurai
IXR	IXR	IN	Airport	23.3142	85.3217	Asia/Kolkata	5.5	Ranchi
IXS	IXS	IN	Airport	24.9131	92.9786	Asia/Kolkata	5.5	Silchar
IXU	IXU	IN	Airport	19.8628	75.3981	Asia/Kolkata	5.5	Aurangabad
IXZ	IXZ	IN	Airport	11.6411	92.7297	Asia/Kolkata	5.5	Port Blair
JAC	JAC	US	Airport	43.6072	-110.7378	America/Denver	-6.0	Jackson, WY
JAI	JAI	IN	Airport	26.8242	75.8122	Asia/Kolkata	5.5	Jaipur
JAN	JAN	US	Airport	32.3111	-90.0758	America/Chicago	-5.0	Jackson, Mississippi - International
JAX	JAX	US	Airport	30.4942	-81.6878	America/New_York	-4.0	Jacksonville, International, FL
JDH	JDH	IN	Airport	26.2511	73.0489	Asia/Kolkata	5.5	Jodhpur
JDZ	JDZ	CN	Airport	29.3392	117.1764	Asia/Shanghai	8.0	Jingdezhen
JED	JED	SA	Airport	21.6794	39.1567	Asia/Riyadh	3.0	Jeddah - King Abdul Aziz International
JER	JER	GB	Airport	49.2078	-2.1953	Europe/London	1.0	Jersey
JFK	NYC	US	Airport	40.6397	-73.7789	America/New_York	-4.0	New York - JFK International, NY
JGA	JGA	IN	Airport	22.4656	70.0125	Asia/Kolkata	5.5	Jamnagar
JHB	JHB	MY	Airport	1.6389	103.6703	Asia/Kuala_Lumpur	8.0	Johor Bahru - Sultan Ismail International
JHM	JHM	US	Airport	20.9631	-156.6731	Pacific/Honolulu	-10.0	Kapalua
JIB	JIB	DJ	Airport	11.5472	43.1594	Africa/Djibouti	3.0	Djibouti
JIJ	JIJ	ET	Airport	9.3633	42.7897	Africa/Addis_Ababa	3.0	Jijiga
JIM	JIM	ET	Airport	7.6628	36.8181	Africa/Addis_Ababa	3.0	Jimma
JJN	JJN	CN	Airport	24.7956	118.5881	Asia/Shanghai	8.0	Quanzhou
JKG	JKG	SE	Airport	57.7575	14.0686	Europe/Stockholm	2.0	Jonkoping
JKH	JKH	GR	Airport	38.3431	26.1406	Europe/Athens	3.0	Chios
JLR	JLR	IN	Airport	23.1778	80.0519	Asia/Kolkata	5.5	Jabalpur
JMK	JMK	GR	Airport	37.435	25.3481	Europe/Athens	3.0	Mykonos
JMS	JMS	US	Airport	46.9297	-98.6783	America/Chicago	-5.0	Jamestown, North Dakota
JMU	JMU	CN	Airport	46.8433	130.4653	Asia/Shanghai	8.0	Jiamusi
LUX	LUX	LU	Airport	49.6233	6.2044	Europe/Luxembourg	2.0	Luxemburg
JNB	JNB	ZA	Airport	-26.1392	28.2461	Africa/Johannesburg	2.0	Johannesburg- O.R. Tambo International Airport
JOI	JOI	BR	Airport	-26.2244	-48.7975	America/Sao_Paulo	-3.0	Joinville
JOK	JOK	RU	Airport	56.7008	47.8964	Europe/Moscow	3.0	Yoshkar-Ola
JPA	JPA	BR	Airport	-7.1483	-34.9506	America/Araguaina	-3.0	JOAO PESSOA CASTRO PINTO INTL
JRH	JRH	IN	Airport	26.7317	94.1756	Asia/Kolkata	5.5	Jorhat
JRO	JRO	TZ	Airport	-3.4294	37.0744	Africa/Dar_es_Salaam	3.0	Kilimanjaro
JSH	JSH	GR	Airport	35.2161	26.1014	Europe/Athens	3.0	SITEIA
JSI	JSI	GR	Airport	39.1772	23.5036	Europe/Athens	3.0	Skiathos
JTR	JTR	GR	Airport	36.3992	25.4794	Europe/Athens	3.0	Thira
JUB	JUB	SS	Airport	4.8719	31.6011	Africa/Juba	3.0	Juba
JUJ	JUJ	AR	Airport	-24.3928	-65.0978	America/Argentina/Buenos_Aires	-3.0	Jujuy
JUL	JUL	PE	Airport	-15.4672	-70.1581	America/Lima	-5.0	JULIACA INCO MANCO CAPAC INTL
JUZ	JUZ	CN	Airport	28.9672	118.9	Asia/Urumqi	6.0	QUZHOU
KAN	KAN	NG	Airport	12.0475	8.5247	Africa/Lagos	1.0	MALLAM AMINU KANO INTL
KAO	KAO	FI	Airport	65.9875	29.2394	Europe/Helsinki	3.0	Kuusamo
KBL	KBL	AF	Airport	34.5658	69.2125	Asia/Kabul	4.5	KABUL INTERNATIONAL
KBP	IEV	UA	Airport	50.345	30.8947	Europe/Kiev	3.0	Kiev - Boryspil Int´l
KBR	KBR	MY	Airport	6.1675	102.2911	Asia/Kuala_Lumpur	8.0	Kota Bharu
KBV	KBV	TH	Airport	8.0958	98.9889	Asia/Bangkok	7.0	Krabi
KCH	KCH	MY	Airport	1.4842	110.3439	Asia/Kuala_Lumpur	8.0	Kuching
KCM	KCM	TR	Airport	37.5389	36.9533	Europe/Istanbul	3.0	Kahramanmaras
KCZ	KCZ	JP	Airport	33.5461	133.6694	Asia/Tokyo	9.0	Kochi
KEF	REK	IS	Airport	63.985	-22.6056	Atlantic/Reykjavik	0.0	Reykjavik - Keflavik International
KFS	KFS	TR	Airport	41.315	33.7961	Europe/Istanbul	3.0	Kastamonu
KGD	KGD	RU	Airport	54.89	20.5925	Europe/Kaliningrad	2.0	Kaliningrad
KGL	KGL	RW	Airport	-1.9686	30.1394	Africa/Kigali	2.0	Kigali
KGS	KGS	GR	Airport	36.7933	27.0917	Europe/Athens	3.0	Kos
KHE	KHE	UA	Airport	46.6772	32.5072	Europe/Kiev	3.0	Kherson
KHG	KHG	CN	Airport	39.5425	76.02	Asia/Urumqi	6.0	Kashi
KHH	KHH	TW	Airport	22.5772	120.35	Asia/Taipei	8.0	Kaohsiung International
KHI	KHI	PK	Airport	24.9067	67.1608	Asia/Karachi	5.0	Karachi
KHN	KHN	CN	Airport	28.8639	115.9022	Asia/Shanghai	8.0	Nanchang
KHV	KHV	RU	Airport	48.5281	135.1883	Asia/Vladivostok	10.0	Khabarovsk
KIJ	KIJ	JP	Airport	37.9558	139.1208	Asia/Tokyo	9.0	Niigata
KIM	KIM	ZA	Airport	-28.8028	24.7653	Africa/Johannesburg	2.0	Kimberley
KIN	KIN	JM	Airport	17.9356	-76.7875	America/Jamaica	-5.0	Norman Manley Intl
KIV	KIV	MD	Airport	46.9278	28.9308	Europe/Chisinau	3.0	Chisinau
KIX	OSA	JP	Airport	34.4272	135.2442	Asia/Tokyo	9.0	Osaka - Kansai International
KJA	KJA	RU	Airport	56.1731	92.4933	Asia/Krasnoyarsk	7.0	Krasnoyarsk
KJR	FKB	DE	RailwayStation	0	0	Europe/Berlin	2.0	Karlsruhe - Hbf Railway Station
KKC	KKC	TH	Airport	16.4644	102.7822	Asia/Bangkok	7.0	Khon Kaen
KKE	KKE	NZ	Airport	-35.2578	173.9119	Pacific/Auckland	12.0	Kerikeri
KKJ	KKJ	JP	Airport	33.8458	131.0347	Asia/Tokyo	9.0	Kita Kyushu
KKN	KKN	NO	Airport	69.7258	29.8914	Europe/Oslo	2.0	Kirkenes
KLO	KLO	PH	Airport	11.6844	122.3811	Asia/Manila	8.0	Kalibo
KLR	KLR	SE	Airport	56.6856	16.2875	Europe/Stockholm	2.0	Kalmar
KLT	KLT	DE	RailwayStation	49	7	Europe/Berlin	2.0	Kaiserslautern
KLU	KLU	AT	Airport	46.6428	14.3378	Europe/Vienna	2.0	Klagenfurt
KLX	KLX	GR	Airport	37.0683	22.0256	Europe/Athens	3.0	Kalamata
KMG	KMG	CN	Airport	25.1086	102.935	Asia/Shanghai	8.0	Kunming
KMI	KMI	JP	Airport	31.8772	131.4486	Asia/Tokyo	9.0	Miyazaki
KMJ	KMJ	JP	Airport	32.8372	130.855	Asia/Tokyo	9.0	Kumamoto
KMQ	KMQ	JP	Airport	36.3947	136.4067	Asia/Tokyo	9.0	Komatsu
KNC	KNC	CN	Airport	0	0	Asia/Shanghai	8.0	Ji'An
KNO	MES	ID	Airport	3.6378	98.8719	Asia/Jakarta	7.0	Medan Kuala Namu
KNU	KNU	IN	Airport	26.4406	80.3672	Asia/Kolkata	5.5	Kanpur
KOA	KOA	US	Airport	19.7389	-156.0456	Pacific/Honolulu	-10.0	Kona
KOJ	KOJ	JP	Airport	31.8033	130.7194	Asia/Tokyo	9.0	Kagoshima
KOW	KOW	CN	Airport	25.8514	114.7753	Asia/Urumqi	6.0	Ganzhou Huangjin
KPO	KPO	KR	Airport	35.9878	129.4206	Asia/Seoul	9.0	P'Ohang
KRK	KRK	PL	Airport	50.0778	19.7847	Europe/Warsaw	2.0	Krakow
KRL	KRL	CN	Airport	41.6992	86.1303	Asia/Urumqi	6.0	Korla
KRN	KRN	SE	Airport	67.8219	20.3367	Europe/Stockholm	2.0	Kiruna
KRR	KRR	RU	Airport	45.0325	39.1664	Europe/Moscow	3.0	Krasnodar
KRS	KRS	NO	Airport	58.2042	8.0853	Europe/Oslo	2.0	Kristiansand - Kjevik
KRT	KRT	SD	Airport	15.5894	32.5531	Africa/Khartoum	2.0	Khartoum
KRY	KRY	CN	Airport	45.4661	84.9539	Asia/Urumqi	6.0	Karamay
KSA	KSA	FM	Airport	5.3569	162.9583	Pacific/Kosrae	11.0	Kosrae International
KSC	KSC	SK	Airport	48.6631	21.2411	Europe/Bratislava	2.0	Kosice
KSD	KSD	SE	Airport	59.4447	13.3375	Europe/Stockholm	2.0	Karlstad
KSU	KSU	NO	Airport	63.1117	7.8244	Europe/Oslo	2.0	Kristiansund - Kvernberget
KSY	KSY	TR	Airport	40.5622	43.115	Europe/Istanbul	3.0	Kars
KTM	KTM	NP	Airport	27.6967	85.3592	Asia/Kathmandu	5.75	Kathmandu - Tribhuvan
KTN	KTN	US	Airport	55.3556	-131.7139	America/Anchorage	-8.0	Ketchikan International
KTT	KTT	FI	Airport	67.7011	24.8469	Europe/Helsinki	3.0	Kittila
KTW	KTW	PL	Airport	50.4742	19.08	Europe/Warsaw	2.0	Katowice
KUA	KUA	MY	Airport	3.7808	103.2094	Asia/Kuala_Lumpur	8.0	Kuantan
KUF	KUF	RU	Airport	53.5039	50.1517	Europe/Samara	4.0	Samara Int'l Apt. Kuromoch
KUH	KUH	JP	Airport	43.0408	144.1931	Asia/Tokyo	9.0	Kushiro
KUL	KUL	MY	Airport	3.129722222	101.5519444	Asia/Kuala_Lumpur	8.0	Kuala Lumpur Int'l (Sepang)
KUN	KUN	LT	Airport	54.9639	24.0847	Europe/Vilnius	3.0	Kaunas
KUO	KUO	FI	Airport	63.0072	27.7978	Europe/Helsinki	3.0	Kuopio
KVA	KVA	GR	Airport	40.9133	24.6192	Europe/Athens	3.0	Kavala
KVX	KVX	RU	Airport	58.5008	49.3422	Europe/Moscow	3.0	Kirov
KWA	KWA	MH	Airport	8.72	167.7317	Pacific/Majuro	12.0	Kwajalein Island Bucholz Aaf
KWE	KWE	CN	Airport	26.5386	106.8008	Asia/Shanghai	8.0	Guiyang
KWI	KWI	KW	Airport	29.2267	47.9689	Asia/Kuwait	3.0	Kuwait International
KWJ	KWJ	KR	Airport	35.1264	126.8089	Asia/Seoul	9.0	Gwangju
KWL	KWL	CN	Airport	25.2181	110.0392	Asia/Shanghai	8.0	Guilin
KWQ	KSF	DE	RailwayStation	0	0	Europe/Berlin	2.0	Kassel - Railway Station Wilhelmshoehe
KYA	KYA	TR	Airport	37.9789	32.5619	Europe/Istanbul	3.0	Konya
KZN	KZN	RU	Airport	55.6061	49.2786	Europe/Moscow	3.0	Kazan
LAD	LAD	AO	Airport	-8.8583	13.2311	Africa/Luanda	1.0	Luanda
LAN	LAN	US	Airport	42.7786	-84.5872	America/New_York	-4.0	Lansing
LAP	LAP	MX	Airport	24.0728	-110.3625	America/Mazatlan	-6.0	La Paz
LAR	LAR	US	Airport	41.3119	-105.675	America/Denver	-6.0	Laramie
LAS	LAS	US	Airport	36.08	-115.1522	America/Los_Angeles	-7.0	Las Vegas - McCarran International, NV
LAX	LAX	US	Airport	33.9425	-118.4081	America/Los_Angeles	-7.0	Los Angeles International, CA
LBB	LBB	US	Airport	33.6636	-101.8228	America/Chicago	-5.0	Lubbock International, TX
LBF	LBF	US	Airport	41.1311	-100.6931	America/Chicago	-5.0	North Platte
LBL	LBL	US	Airport	37.0442	-100.96	America/Chicago	-5.0	Liberal
LBU	LBU	MY	Airport	5.2972	115.2525	Asia/Kuala_Lumpur	8.0	Labuan
LBV	LBV	GA	Airport	0.4586	9.4122	Africa/Libreville	1.0	Libreville
LCA	LCA	CY	Airport	34.875	33.6247	Asia/Nicosia	3.0	Larnaca
LCH	LCH	US	Airport	30.1261	-93.2233	America/Chicago	-5.0	Lake Charles
LCJ	LCJ	PL	Airport	51.7219	19.3981	Europe/Warsaw	2.0	Lodz Lublinek Airport
LCY	LON	GB	Airport	51.505	0.0542	Europe/London	1.0	London City Airport
LDB	LDB	BR	Airport	-23.3336	-51.13	America/Sao_Paulo	-3.0	Londrina
LDE	LDE	FR	Airport	43.1856	-0.0028	Europe/Paris	2.0	Lourdes/Tarbes
LED	LED	RU	Airport	59.8003	30.2625	Europe/Moscow	3.0	St. Petersburg - Pulkovo International
LEI	LEI	ES	Airport	36.8439	-2.37	Europe/Madrid	2.0	Almeria
LEJ	LEJ	DE	Airport	51.4325	12.2417	Europe/Berlin	2.0	Leipzig/Halle
LET	LET	CO	Airport	-4.1936	-69.9431	America/Bogota	-5.0	Leticia Alfredo V. Cobo International
LEX	LEX	US	Airport	38.0364	-84.6058	America/New_York	-4.0	Lexington, KY
LFQ	LFQ	CN	Airport	36.0397	111.4917	Asia/Urumqi	6.0	Linfen Qiaoli
LFT	LFT	US	Airport	30.2053	-91.9875	America/Chicago	-5.0	Lafayette, Louisiana - Regional
LFW	LFW	TG	Airport	6.1656	1.2544	Africa/Lome	0.0	Lome
LGA	NYC	US	Airport	40.7772	-73.8725	America/New_York	-4.0	New York - La Guardia
LGB	LGB	US	Airport	33.8178	-118.1517	America/Los_Angeles	-7.0	Long Beach
LGG	LGG	BE	Airport	50.6375	5.4433	Europe/Brussels	2.0	Liege - Bierset
LGK	LGK	MY	Airport	6.3386	99.7322	Asia/Kuala_Lumpur	8.0	Langkawi
LGW	LON	GB	Airport	51.1481	-0.1903	Europe/London	1.0	London
LHE	LHE	PK	Airport	31.5217	74.4036	Asia/Karachi	5.0	Lahore
LHR	LON	GB	Airport	51.4775	-0.4614	Europe/London	1.0	London Heathrow
LHW	LHW	CN	Airport	36.5167	103.6167	Asia/Shanghai	8.0	Lanzhou - Lanzhou Airport
LIH	LIH	US	Airport	21.9764	-159.3361	Pacific/Honolulu	-10.0	Kauai Island - Lihue
LIM	LIM	PE	Airport	-12.0219	-77.1144	America/Lima	-5.0	Lima
LIN	MIL	IT	Airport	45.4494	9.2783	Europe/Rome	2.0	Milan Linate
LIR	LIR	CR	Airport	10.5933	-85.5444	America/Costa_Rica	-6.0	Liberia
LIS	LIS	PT	Airport	38.7742	-9.1342	Europe/Lisbon	1.0	Lisbon – Aeroporto de Lisboa
LIT	LIT	US	Airport	34.7294	-92.2244	America/Chicago	-5.0	Little Rock
LJG	LJG	CN	Airport	26.6742	100.2436	Asia/Urumqi	6.0	Lijiang Sanyi
LJU	LJU	SI	Airport	46.22361111	14.4575	Europe/Ljubljana	2.0	Ljubljana
LKO	LKO	IN	Airport	26.7606	80.8894	Asia/Kolkata	5.5	Lucknow
LLA	LLA	SE	Airport	65.5439	22.1219	Europe/Stockholm	2.0	Lulea
LLI	LLI	ET	Airport	11.975	38.98	Africa/Addis_Ababa	3.0	Lalibela
LLW	LLW	MW	Airport	-13.7894	33.7811	Africa/Blantyre	2.0	Lilongwe - Kamuzu International
LMP	LMP	IT	Airport	35.4981	12.6183	Europe/Rome	2.0	Lampedusa
LNK	LNK	US	Airport	40.8511	-96.7592	America/Chicago	-5.0	Lincoln, NE
LNY	LNY	US	Airport	20.7856	-156.9514	Pacific/Honolulu	-10.0	Lanai City
LNZ	LNZ	AT	Airport	48.2333	14.1875	Europe/Vienna	2.0	Linz - Blue Danube
LOS	LOS	NG	Airport	6.5775	3.3211	Africa/Lagos	1.0	Lagos
LPA	LPA	ES	Airport	27.9319	-15.3867	Atlantic/Canary	1.0	Las Palmas - Aeropuerto de Gran Canaria
LPB	LPB	BO	Airport	-16.5133	-68.1922	America/La_Paz	-4.0	La Paz
LPI	LPI	SE	Airport	58.4022	15.5256	Europe/Stockholm	2.0	Linkoping
LPQ	LPQ	LA	Airport	19.8978	102.1608	Asia/Vientiane	7.0	Luang Prabang
LPT	LPT	TH	Airport	18.2722	99.5042	Asia/Bangkok	7.0	Lampang
LRD	LRD	US	Airport	27.5439	-99.4617	America/Chicago	-5.0	Laredo International
LRM	LRM	DO	Airport	18.4508	-68.9119	America/Santo_Domingo	-4.0	La Romana
LSC	LSC	CL	Airport	-29.9164	-71.1994	America/Santiago	-4.0	La Serena
LSP	LSP	VE	Airport	11.7808	-70.1514	America/Caracas	-4.0	Las Piedras
LST	LST	AU	Airport	-41.5453	147.2111	Australia/Hobart	10.0	Launceston
LTN	LON	GB	Airport	51.8747	-0.3683	Europe/London	1.0	London Luton Apt
LUG	LUG	CH	Airport	46.0042	8.9106	Europe/Zurich	2.0	Lugano
LUN	LUN	ZM	Airport	-15.3308	28.4525	Africa/Lusaka	2.0	Lusaka
LUZ	LUZ	PL	Airport	51.2314	22.6906	Europe/Warsaw	2.0	Lublin
LVI	LVI	ZM	Airport	-17.8217	25.8228	Africa/Lusaka	2.0	Livingstone
LWB	LWB	US	Airport	37.8561	-80.4019	America/New_York	-4.0	Lewisburg
LWO	LWO	UA	Airport	49.8125	23.9561	Europe/Kiev	3.0	Lviv
LWS	LWS	US	Airport	46.3756	-117.0136	America/Los_Angeles	-7.0	Lewiston
LXA	LXA	CN	Airport	29.2981	90.9122	Asia/Urumqi	6.0	Lhasa/Lasa Gonggar
LXR	LXR	EG	Airport	25.6711	32.7067	Africa/Cairo	2.0	Luxor
LXS	LXS	GR	Airport	39.9169	25.2364	Europe/Athens	3.0	Lemnos
LYH	LYH	US	Airport	37.3267	-79.2006	America/New_York	-4.0	Lynchburg
LYI	LYI	CN	Airport	35.0494	118.4119	Asia/Shanghai	8.0	Linyi
LYR	LYR	NO	Airport	78.2461	15.4656	Arctic/Longyearbyen	2.0	Longyearbyen - Svalbard
LYS	LYS	FR	Airport	45.7256	5.0811	Europe/Paris	2.0	Lyon Saint Exupéry
LZH	LZH	CN	Airport	24.2078	109.3914	Asia/Shanghai	8.0	Liuzhou
LZS	LNZ	AT	RailwayStation	48.2906	14.2911	Europe/Vienna	2.0	Linz Rail Station
LZY	LZY	CN	Airport	29.3058	94.3386	Asia/Urumqi	6.0	Nyingchi/Linzhi Mainling/Milin
MAA	MAA	IN	Airport	12.9944	80.1806	Asia/Kolkata	5.5	Chennai/Madras
MAD	MAD	ES	Airport	40.4936	-3.5667	Europe/Madrid	2.0	Madrid Barajas
MAF	MAF	US	Airport	31.9425	-102.2019	America/Chicago	-5.0	Midland Odessa
MAH	MAH	ES	Airport	39.8625	4.2186	Europe/Madrid	2.0	Menorca - Mahon
MAJ	MAJ	MH	Airport	7.0647	171.2719	Pacific/Majuro	12.0	Majuro Amata Kabua International
MAN	MAN	GB	Airport	53.3536	-2.275	Europe/London	1.0	Manchester
MAO	MAO	BR	Airport	-3.0386	-60.0497	America/Porto_Velho	-4.0	Manaus - Eduardo Gomez International
MAR	MAR	VE	Airport	10.5583	-71.7278	America/Caracas	-4.0	Maracaibo
MBA	MBA	KE	Airport	-4.0281	39.5997	Africa/Nairobi	3.0	Mombasa - Moi International
MBE	MBE	JP	Airport	44.3039	143.4042	Asia/Tokyo	9.0	Monbetsu
MBJ	MBJ	JM	Airport	18.5036	-77.9133	America/Jamaica	-5.0	Montego Bay - Sangster International
MBS	MBS	US	Airport	43.5319	-84.0825	America/New_York	-4.0	Saginaw
MCI	MKC	US	Airport	39.2975	-94.7139	America/Chicago	-5.0	Kansas City, International, MO
MCK	MCK	US	Airport	40.2078	-100.5928	America/Chicago	-5.0	Mccook
MCO	ORL	US	Airport	28.4294	-81.3089	America/New_York	-4.0	Orlando International, FL
MCT	MCT	OM	Airport	23.5928	58.2817	Asia/Muscat	4.0	Muscat International
MCZ	MCZ	BR	Airport	-9.5108	-35.7917	America/Belem	-3.0	Maceio
MDC	MDC	ID	Airport	1.5492	124.9264	Asia/Makassar	8.0	Manado
MDE	MDE	CO	Airport	6.1644	-75.4231	America/Bogota	-5.0	Medellin - Jose Maria Cordova
MDL	MDL	MM	Airport	21.7022	95.9781	Asia/Rangoon	6.5	Mandalay
MDT	HAR	US	Airport	40.1936	-76.7633	America/New_York	-4.0	Harrisburg, International, PA
MDZ	MDZ	AR	Airport	-32.8317	-68.7928	America/Argentina/Buenos_Aires	-3.0	Mendoza
MED	MED	SA	Airport	24.5533	39.705	Asia/Riyadh	3.0	Madinah Prince Mohammad Bin Abdulaziz
MEL	MEL	AU	Airport	-37.6733	144.8433	Australia/Sydney	10.0	Melbourne - Tullamarine International
MEM	MEM	US	Airport	35.0425	-89.9767	America/Chicago	-5.0	Memphis International, TN
MES	MES	ID	Airport	3.5581	98.6717	Asia/Jakarta	7.0	Medan
MEX	MEX	MX	Airport	19.4364	-99.0722	America/Mexico_City	-5.0	Mexico City - Aeropuerto Internacional
MFE	MFE	US	Airport	26.1758	-98.2386	America/Chicago	-5.0	McAllen - Miller International
MFM	MFM	MO	Airport	22.1494	113.5917	Asia/Urumqi	6.0	Macau International
MFR	MFR	US	Airport	42.3742	-122.8736	America/Los_Angeles	-7.0	Medford, OR
MGA	MGA	NI	Airport	12.1414	-86.1681	America/Managua	-6.0	Managua
MGF	MGF	BR	Airport	-23.4761	-52.0158	America/Sao_Paulo	-3.0	Maringa
MGM	MGM	US	Airport	32.3006	-86.3939	America/Chicago	-5.0	Montgomery - Dannelly Field
MGQ	MGQ	SO	Airport	2.0147	45.305	Africa/Mogadishu	3.0	Mogadishu Aden Adde Intl
MGW	MGW	US	Airport	39.6411	-79.9175	America/New_York	-4.0	Morgantown
MHD	MHD	IR	Airport	36.2342	59.645	Asia/Tehran	4.5	Mashhad Shahid Hashemi Nejad
MHJ	MHG	DE	RailwayStation	49.4794	8.4692	Europe/Berlin	2.0	Mannheim
MHT	MHT	US	Airport	42.9325	-71.4356	America/New_York	-4.0	Manchester - Boston Regional, NH
MIA	MIA	US	Airport	25.7933	-80.2906	America/New_York	-4.0	Miami International, FL
MID	MID	MX	Airport	20.9369	-89.6578	America/Mexico_City	-5.0	Merida
MIG	MIG	CN	Airport	31.4289	104.7408	Asia/Shanghai	8.0	Mianyang - Nanjiao
MIR	MIR	TN	Airport	35.7581	10.7547	Africa/Tunis	1.0	Monastir Habib Bourguiba International
MJM	MJM	CG	Airport	-6.1211	23.5689	Africa/Lubumbashi	2.0	Mbuji-Mayi
MJT	MJT	GR	Airport	39.0533	26.6022	Europe/Athens	3.0	Mytilene
MKC	MKC	US	Airport	39.1228	-94.5933	America/Chicago	-5.0	Kansas City, Missouri - Johnson Executive
MKE	MKE	US	Airport	42.9472	-87.8967	America/Chicago	-5.0	Milwaukee - General Mitchell, WI
MKG	MKG	US	Airport	43.1694	-86.2383	America/New_York	-4.0	Muskegon
MKK	MKK	US	Airport	21.1517	-157.0978	Pacific/Honolulu	-10.0	Hoolehua
MLA	MLA	MT	Airport	35.8575	14.4775	Europe/Malta	2.0	Malta
MLB	MLB	US	Airport	28.1028	-80.6453	America/New_York	-4.0	Melbourne
MLE	MLE	MV	Airport	5.25	73.51944444	Indian/Maldives	5.0	Male International
MLH	MLH	FR	Airport	47.6008	7.5292	Europe/Zurich	2.0	Mulhouse Euroairport
MLI	MLI	US	Airport	41.4486	-90.5075	America/Chicago	-5.0	Moline, IL
MLM	MLM	MX	Airport	19.85	-101.0256	America/Mexico_City	-5.0	Morelia
MLU	MLU	US	Airport	32.5108	-92.0378	America/Chicago	-5.0	Monroe
MLX	MLX	TR	Airport	38.4353	38.0911	Europe/Istanbul	3.0	Malatya
MMB	MMB	JP	Airport	43.8806	144.1642	Asia/Tokyo	9.0	Memanbetsu
MMH	MMH	US	Airport	37.6244	-118.8406	America/Los_Angeles	-7.0	Mammoth Lakes Mammoth Yosemite
MMK	MMK	RU	Airport	68.7817	32.7508	Europe/Moscow	3.0	Murmansk
PIR	PIR	US	Airport	44.3828	-100.2858	America/Chicago	-5.0	Pierre
MMX	MMA	SE	Airport	55.5425	13.375	Europe/Stockholm	2.0	Malmo - Sturup
MMY	MMY	JP	Airport	24.7828	125.295	Asia/Tokyo	9.0	Miyako
MNL	MNL	PH	Airport	14.5086	121.0194	Asia/Manila	8.0	Manila - Ninoy Aquino International
MOB	MOB	US	Airport	30.6911	-88.2428	America/Chicago	-5.0	Mobile Municipal
MOD	MOD	US	Airport	37.6258	-120.9544	America/Los_Angeles	-7.0	Modesto
MOL	MOL	NO	Airport	62.7447	7.2625	Europe/Oslo	2.0	Molde
MOT	MOT	US	Airport	48.2594	-101.2803	America/Chicago	-5.0	Minot International Apt
MPL	MPL	FR	Airport	43.5833	3.9614	Europe/Paris	2.0	Montpellier
MPM	MPM	MZ	Airport	-25.9208	32.5725	Africa/Maputo	2.0	Maputo International
MQM	MQM	TR	Airport	37.2233	40.6317	Europe/Istanbul	3.0	Mardin
MQP	NLP	ZA	Airport	-25.3831	31.1056	Africa/Johannesburg	2.0	Nelspruit Kruger Mpumalanga Intl
MQX	MQX	ET	Airport	13.4675	39.5333	Africa/Addis_Ababa	3.0	Mekele
MRD	MRD	VE	Airport	8.5822	-71.1611	America/Caracas	-4.0	Merida
MRS	MRS	FR	Airport	43.4367	5.215	Europe/Paris	2.0	Marseille-Provence
MRU	MRU	MU	Airport	-20.4275	57.67638889	Indian/Mauritius	4.0	Mauritius - Seewoosagur International
MRV	MRV	RU	Airport	44.225	43.0819	Europe/Moscow	3.0	Mineralnye Vody
MRY	MRY	US	Airport	36.5869	-121.8431	America/Los_Angeles	-7.0	Monterey Peninsula, CA
MSN	MSN	US	Airport	43.1397	-89.3375	America/Chicago	-5.0	Madison, WI
MSO	MSO	US	Airport	46.9164	-114.0906	America/Denver	-6.0	Missoula International, MT
MSP	MSP	US	Airport	44.8819	-93.2217	America/Chicago	-5.0	Minneapolis - St Paul International, MN
MSQ	MSQ	BY	Airport	53.8825	28.0308	Europe/Minsk	3.0	Minsk
MSU	MSU	LS	Airport	-29.4622	27.5525	Africa/Maseru	2.0	Maseru - Moshoeshoe International
MSY	MSY	US	Airport	29.9933	-90.2581	America/Chicago	-5.0	New Orleans International, LA
MTJ	MTJ	US	Airport	38.5053	-107.8942	America/Denver	-6.0	Montrose County
MTR	MTR	CO	Airport	8.8236	-75.8258	America/Bogota	-5.0	Monteria Los Garzones
MTS	MTS	SZ	Airport	-26.5289	31.3075	Africa/Mbabane	2.0	Manzini - Matsapha International
MTY	MTY	MX	Airport	25.7786	-100.1069	America/Mexico_City	-5.0	Monterrey - Gen. Mariano Escobedo
MUB	MUB	BW	Airport	-19.9725	23.4311	Africa/Gaborone	2.0	Maun
MUC	MUC	DE	Airport	48.3539	11.7861	Europe/Berlin	2.0	Munich
MUN	MUN	VE	Airport	9.7492	-63.1533	America/Caracas	-4.0	Maturin Quiriquire
MVD	MVD	UY	Airport	-34.8383	-56.0308	America/Montevideo	-3.0	Montevideo
MWH	MWH	US	Airport	47.2047	-119.3167	America/Los_Angeles	-7.0	Moses Lake - Grant County
MWX	MWX	KR	Airport	34	126	Asia/Seoul	9.0	Muan
MXP	MIL	IT	Airport	45.63	8.7231	Europe/Rome	2.0	Milan Malpensa
MYE	MYE	JP	Airport	34.0736	139.5603	Asia/Tokyo	9.0	Miyake Jima
MYJ	MYJ	JP	Airport	33.8272	132.6997	Asia/Tokyo	9.0	Matsuyama
MYR	MYR	US	Airport	33.6797	-78.9283	America/New_York	-4.0	Myrtle Beach - International
MYY	MYY	MY	Airport	4.3253	113.9883	Asia/Kuala_Lumpur	8.0	Miri
MZH	MZH	TR	Airport	40.8286	35.5203	Europe/Istanbul	3.0	Amasya Merzifon
MZL	MZL	CO	Airport	5.0297	-75.4647	America/Bogota	-5.0	Manizales
MZR	MZR	AF	Airport	36.7069	67.2094	Asia/Kabul	4.5	Mazar-E Sharif
MZT	MZT	MX	Airport	23.1614	-106.2661	America/Mazatlan	-6.0	Mazatlan
NAG	NAG	IN	Airport	21.0922	79.0472	Asia/Kolkata	5.5	Nagpur
NAN	NAN	FJ	Airport	-17.755	177.4436	Pacific/Fiji	12.0	Nadi International
NAP	NAP	IT	Airport	40.8844	14.2908	Europe/Rome	2.0	Naples - Capodichino
NAS	NAS	BS	Airport	25.0389	-77.4661	America/Nassau	-4.0	Nassau - International
NAT	NAT	BR	Airport	-5.7681	-35.3761	America/Belem	-3.0	Natal
NAV	NAV	TR	Airport	38.7719	34.5344	Europe/Istanbul	3.0	Nevsehir
NBC	NBC	RU	Airport	55.5667	52.1	Europe/Moscow	3.0	Nishnekamsk
NBE	NBE	TN	Airport	36.0756	10.4383	Africa/Tunis	1.0	Enfidha - Hammamet
NBO	NBO	KE	Airport	-1.319166667	36.92777778	Africa/Nairobi	3.0	Nairobi - Jomo Kenyatta International
NCE	NCE	FR	Airport	43.6653	7.215	Europe/Paris	2.0	Nice
NCL	NCL	GB	Airport	55.0375	-1.6917	Europe/London	1.0	Newcastle International
NDG	NDG	CN	Airport	47.2397	123.9181	Asia/Shanghai	8.0	Qiqihar
NDJ	NDJ	TD	Airport	12.1336	15.0339	Africa/Ndjamena	1.0	Ndjamena
NDR	NDR	MA	Airport	34.9889	-3.0283	Africa/Casablanca	1.0	Nador
NGB	NGB	CN	Airport	29.8267	121.4619	Asia/Shanghai	8.0	Ningbo
NGO	NGO	JP	Airport	35.25166667	136.9275	Asia/Tokyo	9.0	Nagoya
NGS	NGS	JP	Airport	32.9169	129.9136	Asia/Tokyo	9.0	Nagasaki
NIM	NIM	NE	Airport	13.4811	2.1767	Africa/Niamey	1.0	Niamey
NKC	NKC	MR	Airport	18.0978	-15.9481	Africa/Nouakchott	0.0	Nouakchott
NKG	NKG	CN	Airport	31.7419	118.8619	Asia/Shanghai	8.0	Nanjing
NLA	NLA	ZM	Airport	-12.9978	28.6661	Africa/Lusaka	2.0	Ndola
NLK	NLK	NF	Airport	-29.0417	167.9386	Pacific/Norfolk	11.0	Norfolk Island
NLP	NLP	ZA	Airport	-25.5	30.9167	Africa/Johannesburg	2.0	Nelspruit
NNG	NNG	CN	Airport	22.6083	108.1725	Asia/Shanghai	8.0	Nanning
NNM	NNM	RU	Airport	67.6403	53.1225	Europe/Moscow	3.0	Naryan-Mar
NOC	NOC	IE	Airport	53.9103	-8.8186	Europe/Dublin	1.0	Knock - Ireland West
NOS	NOS	MG	Airport	-13.3119	48.3147	Indian/Antananarivo	3.0	Nosy-Be Fascene
NOU	NOU	NC	Airport	-22.0144	166.2131	Pacific/Noumea	11.0	Noumea - La Tontouta
NPE	NPE	NZ	Airport	-39.4644	176.8678	Pacific/Auckland	12.0	Napier/Hastings
NQN	NQN	AR	Airport	-38.9489	-68.1558	America/Argentina/Buenos_Aires	-3.0	Neuquen
NQY	NQY	GB	Airport	50.4433	-5.0017	Europe/London	1.0	Newquay
NRK	NRK	SE	Airport	58.5861	16.2486	Europe/Stockholm	2.0	Norrkoping
NRN	DUS	DE	Airport	51.6025	6.1422	Europe/Berlin	2.0	Duesseldorf Weeze Airport
NRT	TYO	JP	Airport	35.7647	140.3864	Asia/Tokyo	9.0	Tokyo - Narita
NSI	YAO	CM	Airport	3.7225	11.5533	Africa/Douala	1.0	Yaounde - Nsimalen Airport
NSN	NSN	NZ	Airport	-41.2967	173.2242	Pacific/Auckland	12.0	Nelson
NST	NST	TH	Airport	8.5397	99.9447	Asia/Bangkok	7.0	Nakhon Si Thammarat
NTE	NTE	FR	Airport	47.1569	-1.6078	Europe/Paris	2.0	Nantes
NTG	NTG	CN	Airport	32.0722	120.9803	Asia/Shanghai	8.0	Nantong
NTQ	NTQ	JP	Airport	37.2925	136.9589	Asia/Tokyo	9.0	Noto Airport
NUE	NUE	DE	Airport	49.4986	11.0669	Europe/Berlin	2.0	Nuremberg
NVA	NVA	CO	Airport	2.9503	-75.2939	America/Bogota	-5.0	Neiva Benito Salas
NVT	NVT	BR	Airport	-26.88	-48.6514	America/Sao_Paulo	-3.0	Navegantes
OAJ	OAJ	US	Airport	34.7083	-77.4397	America/New_York	-4.0	Jacksonville, North Carolina
OAK	OAK	US	Airport	37.7214	-122.2208	America/Los_Angeles	-7.0	Oakland International, CA
OAX	OAX	MX	Airport	17.0028	-96.725	America/Mexico_City	-5.0	Oaxaca
OBO	OBO	JP	Airport	42.7333	143.2167	Asia/Tokyo	9.0	Obihiro
ODS	ODS	UA	Airport	46.4267	30.6764	Europe/Kiev	3.0	Odessa
OER	OER	SE	Airport	63.4083	18.99	Europe/Stockholm	2.0	Ornskoldsvik
OGG	OGG	US	Airport	20.8986	-156.4306	Pacific/Honolulu	-10.0	Kahului, HI
OGU	OGU	TR	Airport	40.9669	38.0858	Europe/Istanbul	3.0	Ordu Giresun
OGZ	OGZ	RU	Airport	43.205	44.6067	Europe/Moscow	3.0	Vladikavkaz
OIM	OIM	JP	Airport	34.7819	139.3603	Asia/Tokyo	9.0	Oshima
OIT	OIT	JP	Airport	33.4794	131.7372	Asia/Tokyo	9.0	Oita
OKA	OKA	JP	Airport	26.1958	127.6458	Asia/Tokyo	9.0	Okinawa - Naha
OKC	OKC	US	Airport	35.3931	-97.6008	America/Chicago	-5.0	Oklahoma City - Will Rodgers World, OK
OKJ	OKJ	JP	Airport	34.7569	133.8553	Asia/Tokyo	9.0	Okayama
OLB	OLB	IT	Airport	40.8986	9.5178	Europe/Rome	2.0	Olbia
OMA	OMA	US	Airport	41.3031	-95.8942	America/Chicago	-5.0	Omaha - Eppley Airfield, NE
OME	OME	US	Airport	64.5122	-165.4453	America/Anchorage	-8.0	Nome
OMO	OMO	BA	Airport	43.2828	17.8458	Europe/Sarajevo	2.0	Mostar
ONJ	ONJ	JP	Airport	40.1919	140.3714	Asia/Tokyo	9.0	Odate Noshiro
ONT	ONT	US	Airport	34.0561	-117.6011	America/Los_Angeles	-7.0	Ontario International, CA
OOL	OOL	AU	Airport	-28.1644	153.5047	Australia/Brisbane	10.0	Gold Coast, Queensland
OPO	OPO	PT	Airport	41.2356	-8.6781	Europe/Lisbon	1.0	Porto
ORB	ORB	SE	Airport	59.2236	15.0381	Europe/Stockholm	2.0	Orebro
ORD	CHI	US	Airport	41.9786	-87.9047	America/Chicago	-5.0	Chicago - O'Hare International, IL
ORF	ORF	US	Airport	36.8947	-76.2011	America/New_York	-4.0	Norfolk International, VA
ORK	ORK	IE	Airport	51.8414	-8.4911	Europe/Dublin	1.0	Cork
ORY	PAR	FR	Airport	48.7233	2.3794	Europe/Paris	2.0	Paris
OSD	OSD	SE	Airport	63.1944	14.5003	Europe/Stockholm	2.0	Ostersund
OSI	OSI	HR	Airport	45.4628	18.8103	Europe/Zagreb	2.0	Osijek
OSL	OSL	NO	Airport	60.1939	11.1003	Europe/Oslo	2.0	Oslo
OTH	OTH	US	Airport	43.4172	-124.2461	America/Los_Angeles	-7.0	North Bend Southwest Oregon Rgnl
OTP	BUH	RO	Airport	44.5722	26.1022	Europe/Bucharest	3.0	Bucharest – Henri Coanda
OTZ	OTZ	US	Airport	66.8886	-162.5942	America/Anchorage	-8.0	Kotzebue
OUA	OUA	BF	Airport	12.3533	-1.5125	Africa/Ouagadougou	0.0	Ouagadougou
OUL	OUL	FI	Airport	64.93	25.3544	Europe/Helsinki	3.0	Oulu
OXB	OXB	GW	Airport	11.8947	-15.6536	Africa/Bissau	0.0	Bissau
OXR	OXR	US	Airport	34.2	-119.2	America/Los_Angeles	-7.0	Oxnard/Ventura
OZH	OZH	UA	Airport	47.8669	35.3156	Europe/Kiev	3.0	Zaporizhia Mokraya Intl
PAD	PAD	DE	Airport	51.61166667	8.615277778	Europe/Berlin	2.0	Paderborn
PAH	PAH	US	Airport	37.0603	-88.7731	America/Chicago	-5.0	Paducah
PAP	PAP	HT	Airport	18.58	-72.2925	America/Port-au-Prince	-4.0	Port Au Prince Toussaint Louverture
PAS	PAS	GR	Airport	37.0103	25.1286	Europe/Athens	3.0	Paros
PAT	PAT	IN	Airport	25.5914	85.0881	Asia/Kolkata	5.5	Patna
PBC	PBC	MX	Airport	19.1581	-98.3714	America/Mexico_City	-5.0	Puebla
PBG	PBG	US	Airport	44.6525	-73.4689	America/New_York	-4.0	Plattsburgh International
PBI	PBI	US	Airport	26.6831	-80.0956	America/New_York	-4.0	West Palm Beach International, FL
PDL	PDL	PT	Airport	37.7411	-25.6978	Atlantic/Azores	0.0	Ponta Delgada Joao Paulo Ii
PDP	PDP	UY	Airport	-34.8569	-55.1008	America/Montevideo	-3.0	Punta Del Este
PDX	PDX	US	Airport	45.5886	-122.5975	America/Los_Angeles	-7.0	Portland International, OR
PEE	PEE	RU	Airport	57.9144	56.0211	Asia/Yekaterinburg	5.0	Perm
PEG	PEG	IT	Airport	43.0972	12.5103	Europe/Rome	2.0	Perugia
PEI	PEI	CO	Airport	4.8128	-75.7394	America/Bogota	-5.0	Pereira
PEK	BJS	CN	Airport	40.08	116.5844	Asia/Shanghai	8.0	Beijing (BJS) - Capital
PEM	PEM	PE	Airport	-12.6164	-69.2292	America/Lima	-5.0	Puerto Maldonado Padre Aldamiz Intl
PEN	PEN	MY	Airport	5.2972	100.2767	Asia/Kuala_Lumpur	8.0	Penang - International
PER	PER	AU	Airport	-31.9403	115.9669	Australia/Perth	8.0	Perth
PEW	PEW	PK	Airport	33.9939	71.5144	Asia/Karachi	5.0	Peshawar
PFN	PFN	US	Airport	30.2289	-85.6828	America/Panama	-5.0	Panama City - Bay County
PFO	PFO	CY	Airport	34.7181	32.4858	Asia/Nicosia	3.0	Paphos
PGA	PGA	US	Airport	36.9242	-111.4478	America/Phoenix	-7.0	Page
PGV	PGV	US	Airport	35.6358	-77.3842	America/New_York	-4.0	Greenville, North Carolina - Pitt/Greenville
PHC	PHC	NG	Airport	5.0156	6.9497	Africa/Lagos	1.0	Port Harcourt International
PHF	PHF	US	Airport	37.1319	-76.4931	America/New_York	-4.0	Newport News - Hampton, Virginia
PHL	PHL	US	Airport	39.8719	-75.2411	America/New_York	-4.0	Philadelphia International, PA
PHW	PHW	ZA	Airport	-23.9369	31.1561	Africa/Johannesburg	2.0	Phalaborwa
PHX	PHX	US	Airport	33.4342	-112.0117	America/Phoenix	-7.0	Phoenix - Sky Harbor International, AZ
PIA	PIA	US	Airport	40.6642	-89.6933	America/Chicago	-5.0	Peoria, IL
PIT	PIT	US	Airport	40.4914	-80.2328	America/New_York	-4.0	Pittsburgh International, PA
PKB	PKB	US	Airport	39.345	-81.4392	America/New_York	-4.0	Parkersburg/Marietta
PKU	PKU	ID	Airport	0.4608	101.4444	Asia/Jakarta	7.0	Pekanbaru
PLM	PLM	ID	Airport	-2.8983	104.7	Asia/Jakarta	7.0	Palembang
PLQ	PLQ	LT	Airport	55.9733	21.0939	Europe/Vilnius	3.0	Klaipeda/Palanga Palanga International
PLS	PLS	TC	Airport	21.7736	-72.2658	America/Grand_Turk	-4.0	Providenciales International
PLZ	PLZ	ZA	Airport	-33.985	25.6172	Africa/Johannesburg	2.0	Port Elizabeth
PMC	PMC	CL	Airport	-41.4389	-73.0939	America/Santiago	-4.0	Puerto Montt
PMI	PMI	ES	Airport	39.5517	2.7389	Europe/Madrid	2.0	Palma de Mallorca
PMO	PMO	IT	Airport	38.1819	13.0994	Europe/Rome	2.0	Palermo
PMR	PMR	NZ	Airport	-40.32	175.6136	Pacific/Auckland	12.0	Palmerston North
PMV	PMV	VE	Airport	10.9131	-63.9675	America/Caracas	-4.0	Porlamar
PNA	PNA	ES	Airport	42.77055556	-1.647222222	Europe/Madrid	2.0	Pamplona
PNH	PNH	KH	Airport	11.5467	104.8442	Asia/Phnom_Penh	7.0	Phnom-Penh
PNI	PNI	FM	Airport	6.9853	158.2089	Pacific/Kosrae	11.0	Pohnpei International
PNL	PNL	IT	Airport	36.815	11.9681	Europe/Rome	2.0	Pantelleria
PNQ	PNQ	IN	Airport	18.5822	73.9197	Asia/Kolkata	5.5	Pune
PNR	PNR	CG	Airport	-4.8161	11.8867	Africa/Brazzaville	1.0	Pointe Noire
PNS	PNS	US	Airport	30.4733	-87.1867	America/Chicago	-5.0	Pensacola Municipal
PNZ	PNZ	BR	Airport	-9.3625	-40.5692	America/Araguaina	-3.0	Petrolina Senador Nilo Coelho
POA	POA	BR	Airport	-29.9944	-51.1714	America/Sao_Paulo	-3.0	Porto Alegre
POL	POL	MZ	Airport	-12.9867	40.5225	Africa/Maputo	2.0	Pemba
POP	POP	DO	Airport	19.7578	-70.57	America/Santo_Domingo	-4.0	Puerto Plata
POS	POS	TT	Airport	10.5953	-61.3372	America/Port_of_Spain	-4.0	Port Of Spain Piarco International
POZ	POZ	PL	Airport	52.4211	16.8264	Europe/Warsaw	2.0	Poznan
PPT	PPT	PF	Airport	-17.5539	-149.6072	Pacific/Tahiti	-10.0	Papeete
PRC	PRC	US	Airport	34.6544	-112.4197	America/Phoenix	-7.0	Prescott Ernest A. Love Field
PRG	PRG	CZ	Airport	50.1008	14.26	Europe/Prague	2.0	Prague, Václav Havel Airport
PRN	PRN	RS	Airport	42.57527778	21.03638889	Europe/Belgrade	2.0	Pristina, Kosovo
PSA	PSA	IT	Airport	43.6828	10.3956	Europe/Rome	2.0	Pisa
PSC	PSC	US	Airport	46.2667	-119.1167	America/Los_Angeles	-7.0	Pasco, WA
PSG	PSG	US	Airport	56.8022	-132.9436	America/Anchorage	-8.0	Petersburg
PSO	PSO	CO	Airport	1.3961	-77.2911	America/Bogota	-5.0	Pasto Antonio Narino
PSP	PSP	US	Airport	33.8297	-116.5067	America/Los_Angeles	-7.0	Palm Springs Municipal, CA
PSS	PSS	AR	Airport	-27.3858	-55.9706	America/Argentina/Buenos_Aires	-3.0	Posadas
PTG	UTT	ZA	Airport	-23.8453	29.4586	Africa/Johannesburg	2.0	Polokwane
PTP	PTP	GP	Airport	16.2653	-61.5319	America/Guadeloupe	-4.0	Pointe-A-Pitre
PTY	PTY	PA	Airport	9.07	-79.38361111	America/Panama	-5.0	Panama City - Tocumen International
PUB	PUB	US	Airport	38.2892	-104.4967	America/Denver	-6.0	Pueblo
PUJ	PUJ	DO	Airport	18.5675	-68.3633	America/Santo_Domingo	-4.0	Punta Cana
PUQ	PUQ	CL	Airport	-53.0028	-70.8547	America/Santiago	-4.0	Punta Arenas
PUS	PUS	KR	Airport	35.1767	128.9425	Asia/Seoul	9.0	Busan Gimhae Int' l Airport
PUW	PUW	US	Airport	46.7436	-117.1111	America/Los_Angeles	-7.0	Pullman/Moscow
PUY	PUY	HR	Airport	44.8936	13.9222	Europe/Zagreb	2.0	Pula
PVD	PVD	US	Airport	41.725	-71.4258	America/New_York	-4.0	Providence
PVG	SHA	CN	Airport	31.1433	121.8053	Asia/Shanghai	8.0	Shanghai - Pu Dong
PVH	PVH	BR	Airport	-8.7092	-63.9022	America/Porto_Velho	-4.0	Porto Velho
PVK	PVK	GR	Airport	38.9256	20.7653	Europe/Athens	3.0	Preveza/Lefkada
PVR	PVR	MX	Airport	20.68	-105.2542	America/Mexico_City	-5.0	Puerto Vallarta
PWM	PWM	US	Airport	43.6461	-70.3092	America/New_York	-4.0	Portland Intl, ME
PXO	PXO	PT	Airport	33.0708	-16.3497	Europe/Lisbon	1.0	Porto Santo
PZB	PZB	ZA	Airport	-29.6489	30.3986	Africa/Johannesburg	2.0	Pietermaritzburg
PZO	PZO	VE	Airport	8.2886	-62.7603	America/Caracas	-4.0	Puerto Ordaz
QDU	DUS	DE	Airport	51.2203	6.7931	Europe/Berlin	2.0	Dusseldorf - Train Station
QKL	CGN	DE	RailwayStation	50.9433	6.9583	Europe/Berlin	2.0	Cologne - Railway Station
QKU	CGN	DE	RailwayStation	50.9406	6.9744	Europe/Berlin	2.0	Cologne, Messe Deutz Railway Station
QRO	QRO	MX	Airport	20.6172	-100.1856	America/Mexico_City	-5.0	Queretaro
QUL	QUL	DE	RailwayStation	48.3997	9.9833	Europe/Berlin	2.0	Ulm Rail Station
QWU	QWU	DE	RailwayStation	49.7886	9.9364	Europe/Berlin	2.0	Wuerzburg Rail Station
RAI	RAI	CV	Airport	14.9414	-23.4847	Atlantic/Cape_Verde	-1.0	Praia
RAJ	RAJ	IN	Airport	22.3092	70.7794	Asia/Kolkata	5.5	Rajkot
RAK	RAK	MA	Airport	31.6069	-8.0364	Africa/Casablanca	1.0	Marrakech
RAO	RAO	BR	Airport	-21.1342	-47.7742	America/Sao_Paulo	-3.0	Ribeirao Preto
RAP	RAP	US	Airport	44.0431	-103.0569	America/Denver	-6.0	Rapid City Regional
RAR	RAR	CK	Airport	-21.2028	-159.7983	Pacific/Rarotonga	-10.0	Rarotonga
RCB	RCB	ZA	Airport	-28.7411	32.0922	Africa/Johannesburg	2.0	Richards Bay
RCH	RCH	CO	Airport	11.5261	-72.9258	America/Bogota	-5.0	Riohacha Aimirante Padilla
RDD	RDD	US	Airport	40.5089	-122.2933	America/Los_Angeles	-7.0	Redding
RDM	RDM	US	Airport	44.2542	-121.15	America/Los_Angeles	-7.0	Redmond
RDU	RDU	US	Airport	35.8778	-78.7875	America/New_York	-4.0	Raleigh/Durham, NC
REC	REC	BR	Airport	-8.125833333	-34.92388889	America/Belem	-3.0	Recife - Guararapes International
REG	REG	IT	Airport	38.0719	15.6536	Europe/Rome	2.0	Reggio Calabria - Tito Menniti
REL	REL	AR	Airport	-43.2106	-65.2703	America/Argentina/Buenos_Aires	-3.0	Trelew
REP	REP	KH	Airport	13.4106	103.8128	Asia/Phnom_Penh	7.0	Siem Reap
RES	RES	AR	Airport	-27.45	-59.0561	America/Argentina/Buenos_Aires	-3.0	Resistencia
RGL	RGL	AR	Airport	-51.6089	-69.3128	America/Argentina/Buenos_Aires	-3.0	Rio Gallegos International
RGN	RGN	MM	Airport	16.9072	96.1333	Asia/Rangoon	6.5	Yangon
RHO	RHO	GR	Airport	36.4056	28.0861	Europe/Athens	3.0	Rhodes Diagoras Airport
RIC	RIC	US	Airport	37.5053	-77.3197	America/New_York	-4.0	Richmond - Byrd Field International, VA
RIS	RIS	JP	Airport	45.2419	141.1864	Asia/Tokyo	9.0	Rishiri
RIW	RIW	US	Airport	43.0656	-108.46	America/Denver	-6.0	Riverton
RIX	RIX	LV	Airport	56.9236	23.9711	Europe/Riga	3.0	Riga
RJK	RJK	HR	Airport	45.2169	14.5703	Europe/Zagreb	2.0	Rijeka
RKS	RKS	US	Airport	41.5947	-109.0656	America/Denver	-6.0	Rock Springs
RLG	RLG	DE	Airport	53.91805556	12.27833333	Europe/Berlin	2.0	Rostock-Laage
RMF	RMF	EG	Airport	25.5572	34.5836	Africa/Cairo	2.0	Marsa Alam
RMI	RMI	IT	Airport	44.0194	12.6094	Europe/Rome	2.0	Rimini
RNB	RNB	SE	Airport	56.2667	15.265	Europe/Stockholm	2.0	Ronneby
RNO	RNO	US	Airport	39.4992	-119.7681	America/Los_Angeles	-7.0	Reno - Cannon International, NV
ROA	ROA	US	Airport	37.3256	-79.9756	America/New_York	-4.0	Roanoke, VA
ROB	MLW	LR	Airport	6.2339	-10.3622	Africa/Monrovia	0.0	Monrovia - Robertsville International
ROC	ROC	US	Airport	43.1189	-77.6725	America/New_York	-4.0	Rochester, NY
ROR	ROR	PW	Airport	7.3672	134.5442	Pacific/Palau	9.0	Koror Palau International
ROS	ROS	AR	Airport	-32.9036	-60.7844	America/Argentina/Buenos_Aires	-3.0	Rosario
ROT	ROT	NZ	Airport	-38.1069	176.3164	Pacific/Auckland	12.0	Rotorua
ROV	ROV	RU	Airport	47.2583	39.8181	Europe/Moscow	3.0	Rostov-on-Don
RPR	RPR	IN	Airport	21.1803	81.7389	Asia/Kolkata	5.5	Raipur
RST	RST	US	Airport	43.9103	-92.4967	America/Chicago	-5.0	Rochester Municipal
RSU	RSU	KR	Airport	34.8422	127.6169	Asia/Seoul	9.0	Yeosu
RSW	FMY	US	Airport	26.5361	-81.7553	America/New_York	-4.0	Fort Myers - SW Florida Region, FL
RTB	RTB	HN	Airport	16.3169	-86.5231	America/Tegucigalpa	-6.0	Roatan
RTM	RTM	NL	Airport	51.9531	4.4308	Europe/Amsterdam	2.0	Rotterdam
RUH	RUH	SA	Airport	24.9578	46.6989	Asia/Riyadh	3.0	Riyadh - King Khaled International
RZE	RZE	PL	Airport	50.11	22.0189	Europe/Warsaw	2.0	Rzeszow
SAC	SAC	US	Airport	38.5167	-121.5	America/Los_Angeles	-7.0	Sacramento Executive
SAF	SAF	US	Airport	35.6167	-106.0833	America/Denver	-6.0	Santa Fe Municipal
SAH	SAH	YE	Airport	15.4764	44.2197	Asia/Aden	3.0	Sana'a International
SAL	SAL	SV	Airport	13.4408	-89.0558	America/El_Salvador	-6.0	San Salvador - El Salvador International
SAN	SAN	US	Airport	32.73361111	-117.1866667	America/Los_Angeles	-7.0	San Diego Lindberg Field, CA
SAP	SAP	HN	Airport	15.4528	-87.9236	America/Tegucigalpa	-6.0	San Pedro Sula
SAT	SAT	US	Airport	29.5336	-98.4697	America/Chicago	-5.0	San Antonio International, TX
SAV	SAV	US	Airport	32.1275	-81.2022	America/New_York	-4.0	Savannah International, GA
SAW	IST	TR	Airport	40.8986	29.3092	Europe/Istanbul	3.0	Istanbul Sabiha Gokcen Airport
SBA	SBA	US	Airport	34.4261	-119.8403	America/Los_Angeles	-7.0	Santa Barbara Municipal, CA
SBN	SBN	US	Airport	41.7047	-86.3131	America/Indiana/Indianapolis	-4.0	South Bend
SBP	CSL	US	Airport	35.2369	-120.6419	America/Los_Angeles	-7.0	San Luis Obispo County, CA
SBW	SBW	MY	Airport	2.2642	111.9825	Asia/Kuala_Lumpur	8.0	Sibu
SBY	SBY	US	Airport	38.3406	-75.5103	America/New_York	-4.0	Salisbury
SBZ	SBZ	RO	Airport	45.7856	24.0914	Europe/Bucharest	3.0	Sibiu International
SCC	SCC	US	Airport	70.1947	-148.4653	America/Anchorage	-8.0	Prudhoe Bay/Deadhorse
SCE	SCE	US	Airport	40.8506	-77.8472	America/New_York	-4.0	State College
SCL	SCL	CL	Airport	-33.3931	-70.7858	America/Santiago	-4.0	Santiago - Arturo Merino Benitez
SCN	SCN	DE	Airport	49.2147	7.1106	Europe/Berlin	2.0	Saarbruecken - Ensheim
SCO	AKX	KZ	Airport	43.86	51.0919	Asia/Oral	5.0	Aktau
SCQ	SCQ	ES	Airport	42.895	-8.415	Europe/Madrid	2.0	Santiago de Compostela
SCW	SCW	RU	Airport	61.6469	50.845	Europe/Moscow	3.0	Syktyvkar
SCY	SCY	EC	Airport	-0.9103	-89.6175	Pacific/Galapagos	-6.0	San Cristobal Island San Cristobal
SDA	SCN	DE	BusStation	49.2775	7.0272	Asia/Baghdad	3.0	Saarbruecken - Dudweiler Bus Station
SDF	SDF	US	Airport	38.1744	-85.7361	America/New_York	-4.0	Louisville International, KY
SDJ	SDJ	JP	Airport	38.1397	140.9169	Asia/Tokyo	9.0	Sendai
SDK	SDK	MY	Airport	5.9014	118.0611	Asia/Kuala_Lumpur	8.0	Sandakan
SDL	SDL	SE	Airport	62.5281	17.4439	Europe/Stockholm	2.0	Sundsvall
SDQ	SDQ	DO	Airport	18.4297	-69.6689	America/Santo_Domingo	-4.0	Santo Domingo - Las Americas
SDU	RIO	BR	Airport	-22.9106	-43.1631	America/Sao_Paulo	-3.0	Rio de Janeiro - Santos Dumont
SEA	SEA	US	Airport	47.4489	-122.3094	America/Los_Angeles	-7.0	Seattle - Seattle/Tacoma International, WA
SEN	LON	GB	Airport	51.5714	0.6956	Europe/London	1.0	London Southend Apt
SEZ	SEZ	SC	Airport	-4.6744	55.5219	Indian/Mahe	4.0	Mahe Island - Seychelles International
SFN	SFN	AR	Airport	-31.7108	-60.8114	America/Argentina/Buenos_Aires	-3.0	Santa Fe
SFO	SFO	US	Airport	37.6189	-122.3917	America/Los_Angeles	-7.0	San Francisco International, CA
SFT	SFT	SE	Airport	64.6247	21.0769	Europe/Stockholm	2.0	Skelleftea
SGF	SGF	US	Airport	37.2456	-93.3886	America/Chicago	-5.0	Springfield Branson
SGN	SGN	VN	Airport	10.8189	106.6519	Asia/Ho_Chi_Minh	7.0	Ho Chi Minh City
SGU	SGU	US	Airport	37.0906	-113.5931	America/Denver	-6.0	Saint George
SHA	SHA	CN	Airport	31.1978	121.3364	Asia/Urumqi	6.0	Shanghai Hongqiao International Apt
SHB	SHB	JP	Airport	43.5775	144.96	Asia/Tokyo	9.0	Nakashibetsu
SHC	SHC	ET	Airport	14.0794	38.2714	Africa/Addis_Ababa	3.0	Inda Selassie
SHE	SHE	CN	Airport	41.6397	123.4833	Asia/Shanghai	8.0	Shenyang Taoxian International Airport
SHJ	SHJ	AE	Airport	25.3286	55.5172	Asia/Dubai	4.0	Sharjah
SHL	SHL	IN	Airport	25.7036	91.9775	Asia/Kolkata	5.5	Shillong
SHR	SHR	US	Airport	44.7692	-106.9803	America/Denver	-6.0	Sheridan
SHV	SHV	US	Airport	32.4472	-93.8289	America/Chicago	-5.0	Shreveport Regional
SIA	SIA	CN	Airport	34.3761	109.1239	Asia/Shanghai	8.0	Xi'An - Xiguan
SID	SID	CV	Airport	16.7414	-22.9494	Atlantic/Cape_Verde	-1.0	Sal Island Amilcar Cabral International
SIN	SIN	SG	Airport	1.3592	103.9894	Asia/Singapore	8.0	Singapore - Changi International
SIR	SIR	CH	Airport	46.2225	7.34	Europe/Zurich	2.0	Sion
SIS	SIS	ZA	Airport	-27.65	23	Africa/Johannesburg	2.0	Sishen
SIT	SIT	US	Airport	57.0472	-135.3617	America/Anchorage	-8.0	Sitka
SJC	SJC	US	Airport	37.3625	-121.9289	America/Los_Angeles	-7.0	San Jose, California
SJD	SJD	MX	Airport	23.1519	-109.7211	America/Mazatlan	-6.0	San Jose del Cabo - Los Cabos
SJJ	SJJ	BA	Airport	43.8247	18.3314	Europe/Sarajevo	2.0	Sarajevo
SJO	SJO	CR	Airport	9.9939	-84.2089	America/Costa_Rica	-6.0	San Jose - Juan Santamaria International
SJP	SJP	BR	Airport	-20.8167	-49.4064	America/Sao_Paulo	-3.0	Sao Jose Do Rio Preto
SJU	SJU	PR	Airport	18.4394	-66.0019	America/Puerto_Rico	-4.0	San Juan - Luis Munoz Marin International
SJW	SJW	CN	Airport	38.2806	114.6972	Asia/Urumqi	6.0	Shijiazhuang Zhengding International
SKB	SKB	KN	Airport	17.3111	-62.7186	America/St_Kitts	-4.0	St Kitts Robert L Bradshaw Intl
SKG	SKG	GR	Airport	40.52083333	22.97222222	Europe/Athens	3.0	Thessaloniki
SKP	SKP	MK	Airport	41.9617	21.6214	Europe/Skopje	2.0	Skopje
SLA	SLA	AR	Airport	-24.8597	-65.4869	America/Argentina/Buenos_Aires	-3.0	Salta
SLC	SLC	US	Airport	40.7883	-111.9778	America/Denver	-6.0	Salt Lake City International, UT
SLP	SLP	MX	Airport	22.2542	-100.9308	America/Mexico_City	-5.0	San Luis Potosi
SLW	SLW	MX	Airport	25.5439	-100.9283	America/Mexico_City	-5.0	Saltillo
SLZ	SLZ	BR	Airport	-2.5853	-44.2342	America/Belem	-3.0	Sao Luiz
SMF	SAC	US	Airport	38.6956	-121.5908	America/Los_Angeles	-7.0	Sacramento Metropolitan, CA
SMI	SMI	GR	Airport	37.69	26.9117	Europe/Athens	3.0	Samos
SMR	SMR	CO	Airport	11.1197	-74.2306	America/Bogota	-5.0	Santa Marta
SMX	SMX	US	Airport	34.8989	-120.4575	America/Los_Angeles	-7.0	Santa Maria
SNA	SNA	US	Airport	33.6756	-117.8683	America/Los_Angeles	-7.0	Santa Ana (Orange County) - John Wayne\nInternational, CA
SNN	SNN	IE	Airport	52.7019	-8.9247	Europe/Dublin	1.0	Shannon
SNU	SNU	CU	Airport	22.4922	-79.9436	America/Havana	-4.0	Santa Clara
SOC	SOC	ID	Airport	-7.5161	110.7569	Asia/Jakarta	7.0	Surakarta
SOF	SOF	BG	Airport	42.6953	23.4061	Europe/Sofia	3.0	Sofia
SPC	SPC	ES	Airport	28.6264	-17.7556	Atlantic/Canary	1.0	Santa Cruz de la Palma - La Palma
SPI	SPI	US	Airport	39.8442	-89.6778	America/Chicago	-5.0	Springfield, Illinois
SPN	SPN		Airport	15.1189	145.7294	Pacific/Saipan	10.0	Saipan International
SPU	SPU	HR	Airport	43.5389	16.2981	Europe/Zagreb	2.0	Split
SRG	SRG	ID	Airport	-6.9714	110.3742	Asia/Jakarta	7.0	Semarang
SRQ	SRQ	US	Airport	27.3956	-82.5544	America/New_York	-4.0	Sarasota/Bradenton
SSA	SSA	BR	Airport	-12.9111	-38.3311	America/Belem	-3.0	Salvador
SSG	SSG	GQ	Airport	3.7553	8.7086	Africa/Malabo	1.0	Malabo
SSH	SSH	EG	Airport	27.9772	34.395	Africa/Cairo	2.0	Sharm El Sheikh
STI	STI	DO	Airport	19.4061	-70.6047	America/Santo_Domingo	-4.0	Santiago Cibao Intl
STL	STL	US	Airport	38.7486	-90.37	America/Chicago	-5.0	Saint Louis - Lambert-St Louis Intl, MO
STN	LON	GB	Airport	51.88277778	0.233888889	Europe/London	1.0	London-Stansted
STR	STR	DE	Airport	48.69	9.2219	Europe/Berlin	2.0	Stuttgart - Echterdingen
STS	STS	US	Airport	38.5106	-122.8103	America/Los_Angeles	-7.0	Santa Rosa
STT	SNP	US	Airport	18.3372	-64.9733	America/St_Thomas	-4.0	Saint Thomas Island
STV	STV	IN	Airport	21.1142	72.7417	Asia/Kolkata	5.5	Surat
STW	STW	RU	Airport	45.1092	42.1128	Europe/Moscow	3.0	Stavropol
SUB	SUB	ID	Airport	-7.3797	112.7869	Asia/Jakarta	7.0	Surabaya
SUF	SUF	IT	Airport	38.9083	16.2417	Europe/Rome	2.0	Lamezia Terme
SUN	SUN	US	Airport	43.5056	-114.2972	America/Denver	-6.0	Hailey
SVG	SVG	NO	Airport	58.8767	5.6378	Europe/Oslo	2.0	Stavanger
SVO	MOW	RU	Airport	55.9728	37.4147	Europe/Moscow	3.0	Moscow
SVQ	SVQ	ES	Airport	37.4181	-5.8931	Europe/Madrid	2.0	Seville
SVX	SVX	RU	Airport	56.7431	60.8028	Asia/Yekaterinburg	5.0	Ekaterinburg - Koltsovo Int'l
SVZ	SVZ	VE	Airport	7.8408	-72.4397	America/Caracas	-4.0	San Antonio
SWA	SWA	CN	Airport	23.4275	116.7625	Asia/Shanghai	8.0	Shantou
SXB	SXB	FR	Airport	48.5419	7.6344	Europe/Paris	2.0	Strasbourg
SXF	BER	DE	Airport	52.3786	13.5206	Europe/Berlin	2.0	Berlin - Schoenefeld
SXM	SXM	SX	Airport	18.0408	-63.1089	America/Lower_Princes	-4.0	St Maarten Princess Juliana Internation
SXR	SXR	IN	Airport	33.9872	74.7742	Asia/Kolkata	5.5	Srinagar
SYD	SYD	AU	Airport	-33.9461	151.1772	Australia/Sydney	10.0	Sydney - Kingsford Smith International
SYO	SYO	JP	Airport	38.8122	139.7872	Asia/Tokyo	9.0	Shonai
SYR	SYR	US	Airport	43.1111	-76.1064	America/New_York	-4.0	Syracuse - Hancock International, NY
SYX	SYX	CN	Airport	18.3028	109.4122	Asia/Shanghai	8.0	Sanya
SYZ	SYZ	IR	Airport	29.5403	52.5886	Asia/Tehran	4.5	Shiraz
SZF	SZF	TR	Airport	41.2544	36.5672	Europe/Istanbul	3.0	Samsun
SZG	SZG	AT	Airport	47.7933	13.0044	Europe/Vienna	2.0	Salzburg - W.A. Mozart
SZK	SZK	ZA	Airport	-24.9644	31.5906	Africa/Johannesburg	2.0	Skukuza
SZX	SZX	CN	Airport	22.63916667	113.8105556	Asia/Shanghai	8.0	Shenzhen
SZZ	SZZ	PL	Airport	53.5847	14.9022	Europe/Warsaw	2.0	Szczecin
TAB	TAB	TT	Airport	11.1497	-60.8322	America/Port_of_Spain	-4.0	Tobago
TAE	TAE	KR	Airport	35.8942	128.6589	Asia/Seoul	9.0	Daegu
TAK	TAK	JP	Airport	34.2142	134.0156	Asia/Tokyo	9.0	Takamatsu
TAM	TAM	MX	Airport	22.2964	-97.8658	America/Mexico_City	-5.0	Tampico
TAO	TAO	CN	Airport	36.2661	120.3744	Asia/Shanghai	8.0	Qingdao
TAS	TAS	UZ	Airport	41.2578	69.2811	Asia/Tashkent	5.0	Tashkent
TBS	TBS	GE	Airport	41.6692	44.9547	Asia/Tbilisi	4.0	Tbilisi
TBU	TBU	TO	Airport	-21.2444	-175.1436	Pacific/Tongatapu	13.0	Nuku'Alofa Fua'Amotu International
TBZ	TBZ	IR	Airport	38.1339	46.235	Asia/Tehran	4.5	Tabriz
TCZ	TCZ	CN	Airport	24.9378	98.4856	Asia/Urumqi	6.0	Tengchong Tuofeng
TDX	PHS	TH	Airport	12.2744	102.3189	Asia/Bangkok	7.0	Trat
TER	TER	PT	Airport	38.7619	-27.0908	Atlantic/Azores	0.0	Terceira Lajes
TET	TET	MZ	Airport	-16.1047	33.6403	Africa/Maputo	2.0	Tete Matunda
TEZ	TEZ	IN	Airport	26.7067	92.7783	Asia/Kolkata	5.5	Tezpur
TFS	TCI	ES	Airport	28.0444	-16.5725	Atlantic/Canary	1.0	Tenerife Sur
TGD	TGD	ME	Airport	42.3594	19.2519	Europe/Podgorica	2.0	Podgorica
TGG	TGG	MY	Airport	5.3814	103.1047	Asia/Kuala_Lumpur	8.0	Kuala Terengganu - Sultan Mahmood
TGO	TGO	CN	Airport	43.5575	122.2	Asia/Shanghai	8.0	Tongliao
TGU	TGU	HN	Airport	14.0608	-87.2172	America/Tegucigalpa	-6.0	Tegucigalpa
TGZ	TGZ	MX	Airport	16.5619	-93.0261	America/Mexico_City	-5.0	Tuxtla Gutierrez - Llano San Juan
THE	THE	BR	Airport	-5.06	-42.8236	America/Belem	-3.0	Teresina
THS	THS	TH	Airport	17.2378	99.8183	Asia/Bangkok	7.0	Sukhothai
TIA	TIA	AL	Airport	41.415	19.7208	Europe/Tirane	2.0	Tirana - Mother Teresa Apt. Rinas
TIJ	TIJ	MX	Airport	32.5411	-116.9703	America/Tijuana	-7.0	Tijuana
TIR	TIR	IN	Airport	13.6325	79.5433	Asia/Kolkata	5.5	Tirupati
TIV	TIV	ME	Airport	42.4047	18.7233	Europe/Podgorica	2.0	Tivat
TKK	TKK	FM	Airport	7.4619	151.8431	Pacific/Chuuk	10.0	Chuuk International
TKS	TKS	JP	Airport	34.1328	134.6067	Asia/Tokyo	9.0	Tokushima
TKU	TKU	FI	Airport	60.5142	22.2628	Europe/Helsinki	3.0	Turku
TLH	TLH	US	Airport	30.3917	-84.3497	America/New_York	-4.0	Tallahassee
TLL	TLL	EE	Airport	59.4133	24.8325	Europe/Tallinn	3.0	Tallinn
TLN	TLN	FR	Airport	43.0972	6.1461	Europe/Paris	2.0	Toulon/Hyeres Le Palyvestr
TLS	TLS	FR	Airport	43.635	1.3678	Europe/Paris	2.0	Toulouse - Blagnac
TLV	TLV	IL	Airport	32.0072	34.8806	Asia/Jerusalem	3.0	Tel Aviv - Ben Gurion
TMP	TMP	FI	Airport	61.46388889	23.73888889	Europe/Helsinki	3.0	Tampere
TMS	TMS	ST	Airport	0.3781	6.7122	Africa/Sao_Tome	0.0	Sao Tome
TNA	TNA	CN	Airport	36.8572	117.2161	Asia/Urumqi	6.0	Jinan Yaoqiang Intl
TNG	TNG	MA	Airport	35.7269	-5.9169	Africa/Casablanca	1.0	Tangier
TNH	TNH	CN	Airport	42.2531	125.7044	Asia/Urumqi	6.0	Tonghua Sanyuanpu
TNR	TNR	MG	Airport	-18.7969	47.4789	Indian/Antananarivo	3.0	Antananarivo
TOF	TOF	RU	Airport	56.3858	85.2133	Asia/Novosibirsk	7.0	Tomsk
TOP	TOP	US	Airport	39.0667	-95.6167	America/Chicago	-5.0	Topeka - Phillip
TOS	TOS	NO	Airport	69.68138889	18.92166667	Europe/Oslo	2.0	Tromso
TOY	TOY	JP	Airport	36.6483	137.1875	Asia/Tokyo	9.0	Toyama
TPA	TPA	US	Airport	27.9756	-82.5333	America/New_York	-4.0	Tampa International, FL
TPE	TPE	TW	Airport	25.0778	121.2328	Asia/Taipei	8.0	Taipei - Taoyuan Intl
TRC	TRC	MX	Airport	25.5683	-103.4106	America/Mexico_City	-5.0	Torreon
TRD	TRD	NO	Airport	63.4575	10.9242	Europe/Oslo	2.0	Trondheim
TRG	TRG	NZ	Airport	-37.6733	176.1986	Pacific/Auckland	12.0	Tauranga
TRI	TTO	US	Airport	36.4753	-82.4075	America/New_York	-4.0	Bristol
TRN	TRN	IT	Airport	45.2025	7.6494	Europe/Rome	2.0	Turin
TRS	TRS	IT	Airport	45.8275	13.4722	Europe/Rome	2.0	Triest
TRU	TRU	PE	Airport	-8.0847	-79.1094	America/Lima	-5.0	Trujillo C. Martinez De Pinillos
TRV	TRV	IN	Airport	8.4822	76.92	Asia/Kolkata	5.5	Thiruvananthapuram
TRZ	TRZ	IN	Airport	10.7653	78.7097	Asia/Kolkata	5.5	TIRUCHCHIRAPPALLI
TSA	TPE	TW	Airport	25.0697	121.5525	Asia/Taipei	8.0	Taipei Songshan
TSE	TSE	KZ	Airport	51.0231	71.4669	Asia/Qyzylorda	5.0	Astana
TSJ	TSJ	JP	Airport	34.285	129.3306	Asia/Tokyo	9.0	Tsushima
TSN	TSN	CN	Airport	39.1244	117.3461	Asia/Shanghai	8.0	Tianjin
TSR	TSR	RO	Airport	45.81	21.3378	Europe/Bucharest	3.0	Timisoara – Traian Vuia International Airport
TTJ	TTJ	JP	Airport	35.53	134.1667	Asia/Tokyo	9.0	Tottori
TUC	TUC	AR	Airport	-26.8408	-65.1047	America/Argentina/Buenos_Aires	-3.0	Tucuman
TUL	TUL	US	Airport	36.1983	-95.8881	America/Chicago	-5.0	Tulsa International, OK
TUN	TUN	TN	Airport	36.8511	10.2272	Africa/Tunis	1.0	Tunis - Carthage International
TUO	TUO	NZ	Airport	-38.7408	176.085	Pacific/Auckland	12.0	Taupo
TUS	TUS	US	Airport	32.1161	-110.9411	America/Phoenix	-7.0	Tucson International, AZ
TVC	TVC	US	Airport	44.7414	-85.5822	America/New_York	-4.0	Traverse City
TWU	TWU	MY	Airport	4.3133	118.1219	Asia/Kuala_Lumpur	8.0	Tawau
TXG	TXG	TW	Airport	24.15	120.6461	Asia/Taipei	8.0	Taichung
TXL	BER	DE	Airport	52.56027778	13.29555556	Europe/Berlin	2.0	Berlin - Tegel
TXN	TXN	CN	Airport	29.7328	118.2572	Asia/Shanghai	8.0	Huangshan
TYN	TYN	CN	Airport	37.7469	112.6283	Asia/Shanghai	8.0	Taiyuan
TYR	TYR	US	Airport	32.3542	-95.4025	America/Chicago	-5.0	Tyler
TYS	TYS	US	Airport	35.8111	-83.9942	America/New_York	-4.0	Knoxville, TN
TZX	TZX	TR	Airport	40.995	39.7897	Europe/Istanbul	3.0	Trabzon
UBJ	UBJ	JP	Airport	33.93	131.2786	Asia/Tokyo	9.0	Ube
XNN	XNN	CN	Airport	36.5286	102.0403	Asia/Shanghai	8.0	Xining
UBP	UBP	TH	Airport	15.2514	104.8703	Asia/Bangkok	7.0	Ubon Ratchathani - Muang Ubon
UDI	UDI	BR	Airport	-18.8828	-48.2256	America/Sao_Paulo	-3.0	Uberlandia
UDR	UDR	IN	Airport	24.6178	73.8961	Asia/Kolkata	5.5	Udaipur
UFA	UFA	RU	Airport	54.5575	55.8839	Asia/Yekaterinburg	5.0	Ufa
UIO	UIO	EC	Airport	-0.1239	-78.3561	America/Guayaquil	-5.0	Quito Mariscal Sucre Airport
UKB	OSA	JP	Airport	34.6328	135.2239	Asia/Tokyo	9.0	Osaka - Kobe
ULN	ULN	MN	Airport	47.8431	106.7667	Asia/Ulaanbaatar	8.0	Ulaan Baatar
ULY	ULY	RU	Airport	54.4011	48.8028	Europe/Moscow	3.0	Ulyanovsk
UME	UME	SE	Airport	63.7919	20.2828	Europe/Stockholm	2.0	Umea
UPG	UPG	ID	Airport	-5.0617	119.5542	Asia/Makassar	8.0	Ujung Pandang
URC	URC	CN	Airport	43.9072	87.4742	Asia/Shanghai	8.0	Urumqi
URT	URT	TH	Airport	9.1361	99.1392	Asia/Bangkok	7.0	Surat Thani
USH	USH	AR	Airport	-54.8433	-68.2956	America/Argentina/Buenos_Aires	-3.0	Ushuaia
USK	USK	RU	Airport	66.0044	57.3672	Europe/Moscow	3.0	Usinsk
USM	USM	TH	Airport	9.5503	100.0625	Asia/Bangkok	7.0	Ko Samui
USN	USN	KR	Airport	35.5936	129.3517	Asia/Seoul	9.0	Ulsan
UTH	UTH	TH	Airport	17.3864	102.7883	Asia/Bangkok	7.0	Udon Thani
UTN	UTN	ZA	Airport	-28.3992	21.2603	Africa/Johannesburg	2.0	Upington
UTT	UTT	ZA	Airport	-31.5478	28.6742	Africa/Johannesburg	2.0	Umtata
UUS	UUS	RU	Airport	46.8886	142.7175	Asia/Sakhalin	11.0	Yuzhno Sakhalinsk
UVF	SLU	LC	Airport	13.7333	-60.9525	America/St_Lucia	-4.0	Saint Lucia - Hewanorra
VAA	VAA	FI	Airport	63.0506	21.7622	Europe/Helsinki	3.0	Vaasa
VAN	VAN	TR	Airport	38.4683	43.3322	Europe/Istanbul	3.0	Van
VAR	VAR	BG	Airport	43.2319	27.825	Europe/Sofia	3.0	Varna
VAS	VAS	TR	Airport	39.8139	36.9036	Europe/Istanbul	3.0	Sivas
VBY	VBY	SE	Airport	57.6628	18.3461	Europe/Stockholm	2.0	Visby
VCE	VCE	IT	Airport	45.5053	12.3519	Europe/Rome	2.0	Venice - Marco Polo
VCP	SAO	BR	Airport	-23.0081	-47.1347	America/Sao_Paulo	-3.0	Sao Paulo
VCT	VCT	US	Airport	28.8525	-96.9186	America/Chicago	-5.0	Victoria
VDA	VDA	IL	Airport	29.9403	34.9358	Asia/Jerusalem	3.0	Ovda
VEL	VEL	US	Airport	40.4433	-109.5108	America/Denver	-6.0	Vernal
VER	VER	MX	Airport	19.1458	-96.1872	America/Mexico_City	-5.0	Vera Cruz
VFA	VFA	ZW	Airport	-18.0958	25.8389	Africa/Harare	2.0	Victoria Falls
VGA	VGA	IN	Airport	16.5306	80.7969	Asia/Kolkata	5.5	Vijayawada
VGO	VGO	ES	Airport	42.2317	-8.6267	Europe/Madrid	2.0	Vigo
VIE	VIE	AT	Airport	48.1103	16.5781	Europe/Vienna	2.0	Vienna International
VIX	VIX	BR	Airport	-20.2581	-40.2864	America/Sao_Paulo	-3.0	Vitoria
VKO	MOW	RU	Airport	55.5917	37.2614	Europe/Moscow	3.0	Moscow - Vnukovo
VLC	VLC	ES	Airport	39.4894	-0.4817	Europe/Madrid	2.0	Valencia
VLN	VLN	VE	Airport	10.1497	-67.9283	America/Caracas	-4.0	Valencia
VNO	VNO	LT	Airport	54.6342	25.2858	Europe/Vilnius	3.0	Vilnius
VNS	VNS	IN	Airport	25.4522	82.8594	Asia/Kolkata	5.5	Varanasi
VNX	VNX	MZ	Airport	-22.0183	35.3133	Africa/Maputo	2.0	Vilankulos
VOG	VOG	RU	Airport	48.7825	44.3456	Europe/Moscow	3.0	Volgograd
VOL	VOL	GR	Airport	39.2197	22.7944	Europe/Athens	3.0	Volos
VOZ	VOZ	RU	Airport	51.8142	39.2297	Europe/Moscow	3.0	Voronezh
VPS	VPS	US	Airport	30.4867	-86.52	America/Chicago	-5.0	Valparaiso - Fort Walton Beach
VRA	VRA	CU	Airport	23.0344	-81.4353	America/Havana	-4.0	Varadero
VRN	VRN	IT	Airport	45.3964	10.8881	Europe/Rome	2.0	Verona
VSA	VSA	MX	Airport	17.9969	-92.8175	America/Mexico_City	-5.0	Villahermosa
VTE	VTE	LA	Airport	17.9883	102.5633	Asia/Vientiane	7.0	Vientiane
VTZ	VTZ	IN	Airport	17.7211	83.2244	Asia/Kolkata	5.5	Vishakhapatnam
VVI	SRZ	BO	Airport	-17.6447	-63.1353	America/La_Paz	-4.0	Santa Cruz - Viru Viru International
VVO	VVO	RU	Airport	43.3989	132.1481	Asia/Vladivostok	10.0	Vladivostok
VXE	VXE	CV	Airport	16.8336	-25.0547	Atlantic/Cape_Verde	-1.0	Sao Vicente
WAG	WAG	NZ	Airport	-39.9625	175.0231	Pacific/Auckland	12.0	Wanganui
WAW	WAW	PL	Airport	52.1658	20.9672	Europe/Warsaw	2.0	Warsaw
WDH	WDH	NA	Airport	-22.48333333	17.46666667	Africa/Windhoek	2.0	Windhoek - International
WDS	EJQ	CN	Airport	32.5933	110.9061	Asia/Urumqi	6.0	Shiyan Wudangshan
WEH	WEH	CN	Airport	37.1872	122.2289	Asia/Shanghai	8.0	Weihai
WKJ	WKJ	JP	Airport	45.4042	141.8008	Asia/Tokyo	9.0	Wakkanai
WLG	WLG	NZ	Airport	-41.3269	174.8069	Pacific/Auckland	12.0	Wellington International
WNZ	WNZ	CN	Airport	27.9131	120.8522	Asia/Shanghai	8.0	Wenzhou
WRE	WRE	NZ	Airport	-35.7689	174.3639	Pacific/Auckland	12.0	Whangarei
WRG	WRG	US	Airport	56.4844	-132.3697	America/Anchorage	-8.0	Wrangell
WRL	WRL	US	Airport	43.9644	-107.9531	America/Denver	-6.0	Worland
WRO	WRO	PL	Airport	51.1028	16.8858	Europe/Warsaw	2.0	Wroclaw
WUH	WUH	CN	Airport	30.7839	114.2081	Asia/Shanghai	8.0	Wuhan
WUX	WUX	CN	Airport	31.4947	120.4294	Asia/Shanghai	8.0	Wuxi
WVB	WVB	NA	Airport	-22.98	14.6453	Africa/Windhoek	2.0	Walvis Bay
WXN	WXN	CN	Airport	30.8039	108.4272	Asia/Shanghai	8.0	Wanzhou
XAP	XAP	BR	Airport	-27.1342	-52.6567	America/Sao_Paulo	-3.0	Chapeco Serafin Enoss Bertaso
XER	SXB	FR	Airport	48.5853	7.7356	Europe/Paris	2.0	Strasbourg Bus Station
XFN	XFN	CN	Airport	32.1506	112.2908	Asia/Shanghai	8.0	Xiangyang
XIC	XIC	CN	Airport	27.9892	102.1844	Asia/Urumqi	6.0	Xichang Qingshan
XIL	XIL	CN	Airport	43.9156	115.9633	Asia/Shanghai	8.0	Xilnhot
XIY	SIA	CN	Airport	34.4478	108.7539	Asia/Shanghai	8.0	Xi'An - Xianyang
XMN	XMN	CN	Airport	24.5442	118.1278	Asia/Shanghai	8.0	Xiamen
XNA	FYV	US	Airport	36.0047	-94.17	America/Chicago	-5.0	Fayetteville, AR
XRY	XRY	ES	Airport	36.7447	-6.06	Europe/Madrid	2.0	Jerez De La Frontera - La Parra
XUZ	XUZ	CN	Airport	34.2294	117.2458	Asia/Shanghai	8.0	Xuzhou
YAK	YAK	US	Airport	59.5092	-139.66	America/Anchorage	-8.0	Yakutat
YAM	YAM	CA	Airport	46.485	-84.5094	America/Toronto	-4.0	Sault Sainte Marie
YAO	YAO	CM	Airport	3.8336	11.5236	Africa/Douala	1.0	Yaounde Downtown
YAP	YAP	FM	Airport	9.4989	138.0825	Pacific/Chuuk	10.0	Yap International
YBC	YBC	CA	Airport	49.1325	-68.2044	America/Toronto	-4.0	Baie Comeau
YBG	YBG	CA	Airport	48.3322	-70.9925	America/Toronto	-4.0	Bagotville
YBL	YBL	CA	Airport	49.9508	-125.2706	America/Vancouver	-7.0	Campbell River
YCD	YCD	CA	Airport	49.0522	-123.8703	America/Vancouver	-7.0	Nanaimo - Cassidy
YCG	YCG	CA	Airport	49.2964	-117.6325	America/Vancouver	-7.0	Castlegar
YCU	YCU	CN	Airport	35.1164	111.0336	Asia/Shanghai	8.0	Yuncheng - Guangong
YDF	YDF	CA	Airport	49.2108	-57.3914	America/St_Johns	-2.5	Deer Lake
YEG	YEA	CA	Airport	53.30416667	-113.5916667	America/Edmonton	-6.0	Edmonton - International
YFB	YFB	CA	Airport	63.7564	-68.5558	America/Toronto	-4.0	Iqaluit
YFC	YFC	CA	Airport	45.8689	-66.53	America/Halifax	-3.0	Fredericton
YGJ	YGJ	JP	Airport	35.4922	133.2364	Asia/Tokyo	9.0	Yonago
YGK	YGK	CA	Airport	44.2253	-76.5969	America/Toronto	-4.0	Kingston
YGP	YGP	CA	Airport	48.7753	-64.4786	America/Toronto	-4.0	Gaspe
YGR	YGR	CA	Airport	47.4247	-61.7803	America/Halifax	-3.0	Iles De La Madeleine
YHM	YTO	CA	Airport	43.1619	-79.9281	America/Iqaluit	-4.0	Toronto John C Munro Hamilton
YHZ	YHZ	CA	Airport	44.8869	-63.5128	America/Halifax	-3.0	Halifax - International
YIH	YIH	CN	Airport	30.5569	111.4797	Asia/Shanghai	8.0	Yichang
YIN	YIN	CN	Airport	43.9553	81.3289	Asia/Jakarta	7.0	Yining
YIW	YIW	CN	Airport	29.345	120.0325	Asia/Urumqi	6.0	Yiwu
YKA	YKA	CA	Airport	50.7022	-120.4444	America/Vancouver	-7.0	Kamloops
YKM	YKM	US	Airport	46.5681	-120.5408	America/Los_Angeles	-7.0	Yakima Air Terminal
YLW	YLW	CA	Airport	49.9561	-119.3778	America/Vancouver	-7.0	Kelowna
YMM	YMM	CA	Airport	56.6533	-111.2219	America/Edmonton	-6.0	Fort McMurray
YNB	YNB	SA	Airport	24.1442	38.0633	Asia/Riyadh	3.0	Yanbu Al Bahr
YNJ	YNJ	CN	Airport	42.8828	129.4514	Asia/Shanghai	8.0	Yanji
YNT	YNT	CN	Airport	37.6572	120.9872	Asia/Shanghai	8.0	Yantai
YNZ	YNZ	CN	Airport	33.4261	120.2031	Asia/Shanghai	8.0	Yancheng
YOW	YOW	CA	Airport	45.3225	-75.6692	America/Toronto	-4.0	Ottawa - International
YPR	YPR	CA	Airport	54.2861	-130.4447	America/Vancouver	-7.0	Prince Rupert - Digby Island
YQB	YQB	CA	Airport	46.7911	-71.3933	America/Toronto	-4.0	Quebec
YQG	YQG	CA	Airport	42.2706	-82.9619	America/Toronto	-4.0	Windsor
YQL	YQL	CA	Airport	49.6297	-112.7903	America/Edmonton	-6.0	Lethbridge
YQM	YQM	CA	Airport	46.1069	-64.6925	America/Halifax	-3.0	Moncton
YQQ	YQQ	CA	Airport	49.7108	-124.8867	America/Vancouver	-7.0	Comox
YQR	YQR	CA	Airport	50.4294	-104.6572	America/Regina	-6.0	Regina
YQT	YQT	CA	Airport	48.3719	-89.3239	America/Toronto	-4.0	Thunder Bay
YQU	YQU	CA	Airport	55.1797	-118.885	America/Edmonton	-6.0	Grande Prairie
YQX	YQX	CA	Airport	48.9478	-54.56	America/St_Johns	-2.5	Gander
YQY	YQY	CA	Airport	46.1614	-60.0478	America/Halifax	-3.0	Sydney
YQZ	YQZ	CA	Airport	53.0261	-122.5103	America/Vancouver	-7.0	Quesnel
YSB	YSB	CA	Airport	46.625	-80.7989	America/Toronto	-4.0	Sudbury
YSJ	YSJ	CA	Airport	45.3206	-65.8822	America/Halifax	-3.0	Saint John
YTS	YTS	CA	Airport	48.5697	-81.3767	America/Toronto	-4.0	Timmins
YTY	YTY	CN	Airport	32.5631	119.7189	Asia/Urumqi	6.0	Yangzhou Taizhoui
YTZ	YTO	CA	Airport	43.6275	-79.3961	America/Iqaluit	-4.0	Toronto Bishop Billy City A/P
YUL	YMQ	CA	Airport	45.4706	-73.7408	America/Toronto	-4.0	Montreal - Pierre Elliott Trudeau
YUY	YUY	CA	Airport	48.2061	-78.8356	America/Toronto	-4.0	Rouyn
YVO	YVO	CA	Airport	48.0533	-77.7828	America/Toronto	-4.0	Val D'Or
YVR	YVR	CA	Airport	49.1939	-123.1844	America/Vancouver	-7.0	Vancouver - International
YWG	YWG	CA	Airport	49.9	-97.23333333	America/Winnipeg	-5.0	Winnipeg
YWK	YWK	CA	Airport	52.9219	-66.8644	America/Halifax	-3.0	Wabush
YWL	YWL	CA	Airport	52.1831	-122.0542	America/Vancouver	-7.0	Williams Lake
YXC	YXC	CA	Airport	49.6108	-115.7822	America/Edmonton	-6.0	Cranbrook
YXE	YXE	CA	Airport	52.1708	-106.6997	America/Regina	-6.0	Saskatoon
YXH	YXH	CA	Airport	50.0172	-110.7231	America/Edmonton	-6.0	Medicine Hat
YXJ	YXJ	CA	Airport	56.2381	-120.7403	America/Dawson_Creek	-7.0	Fort Saint John
YXS	YXS	CA	Airport	53.8819	-122.6758	America/Vancouver	-7.0	Prince George
YXT	YXT	CA	Airport	54.4686	-128.5761	America/Vancouver	-7.0	Terrace
YXU	YXU	CA	Airport	43.0356	-81.1539	America/Toronto	-4.0	London (CA)
YXX	YXX	CA	Airport	49.0253	-122.3606	America/Vancouver	-7.0	Abbotsford
YXY	YXY	CA	Airport	60.7094	-135.0672	America/Vancouver	-7.0	Whitehorse
YYB	YYB	CA	Airport	46.3636	-79.4228	America/Toronto	-4.0	North Bay
YYC	YYC	CA	Airport	51.11388889	-114.0202778	America/Edmonton	-6.0	Calgary
YYD	YYD	CA	Airport	54.8247	-127.1828	America/Vancouver	-7.0	Smithers
YYF	YYF	CA	Airport	49.4631	-119.6022	America/Vancouver	-7.0	Penticton
YYG	YYG	CA	Airport	46.2892	-63.1256	America/Halifax	-3.0	Charlottetown
YYJ	YYJ	CA	Airport	48.6469	-123.4258	America/Vancouver	-7.0	Victoria - International
YYR	YYR	CA	Airport	53.3194	-60.4106	America/Halifax	-3.0	Goose Bay
YYT	YYT	CA	Airport	47.61861111	-52.75194444	America/St_Johns	-2.5	Saint John's
YYY	YYY	CA	Airport	48.6086	-68.2081	America/Toronto	-4.0	Mont Joli
YYZ	YTO	CA	Airport	43.6772	-79.6306	America/Toronto	-4.0	Toronto - Pearson Int'l (Lester)
YZF	YZF	CA	Airport	62.4686	-114.4431	America/Edmonton	-6.0	Yellowknife
YZP	YZP	CA	Airport	53.2544	-131.8139	America/Vancouver	-7.0	Sandspit
YZR	YZR	CA	Airport	42.9994	-82.3089	America/Toronto	-4.0	Sarnia
YZV	YZV	CA	Airport	50.2233	-66.2656	America/Toronto	-4.0	Sept-Iles
ZAD	ZAD	HR	Airport	44.1083	15.3467	Europe/Zagreb	2.0	Zadar
ZAG	ZAG	HR	Airport	45.7431	16.0689	Europe/Zagreb	2.0	Zagreb
ZAL	ZAL	CL	Airport	-39.6494	-73.0864	America/Santiago	-4.0	Valdivia
ZAQ	NUE	DE	RailwayStation	49.445	11.0825	Europe/Berlin	2.0	Nuremberg Rail Station
ZBF	ZBF	CA	Airport	47.6297	-65.7389	America/Halifax	-3.0	Bathurst
ZCL	ZCL	MX	Airport	22.8972	-102.6869	America/Mexico_City	-5.0	Zacatecas
ZCO	ZCO	CL	Airport	-38.9269	-72.6469	America/Santiago	-4.0	Temuco
ZDH	ZDH	CH	RailwayStation	47.5478	7.5897	Europe/Zurich	2.0	Basel SBB Railway Station
ZFV	PHL	US	RailwayStation	39.9558	-75.1822	America/New_York	-4.0	Philadelphia 30th Street Rail Station
ZHA	ZHA	CN	Airport	21.2153	110.3583	Asia/Urumqi	6.0	Zhanjiang
ZIH	ZIH	MX	Airport	17.6017	-101.4606	America/Mexico_City	-5.0	Ixtapa/Zihuatanejo International
ZLO	ZLO	MX	Airport	19.1447	-104.5586	America/Mexico_City	-5.0	Manzanillo
ZNZ	ZNZ	TZ	Airport	-6.2219	39.225	Africa/Dar_es_Salaam	3.0	Zanzibar
ZOS	ZOS	CL	Airport	-40.6114	-73.0606	America/Santiago	-4.0	Osorno
ZQN	ZQN	NZ	Airport	-45.0183	168.7467	Pacific/Auckland	12.0	Queenstown
ZRH	ZRH	CH	Airport	47.4647	8.5492	Europe/Zurich	2.0	Zurich
ZSB	ZSB		RailwayStation	47.8131	13.0458	Europe/Vienna	2.0	Salzburg Hbf Rail Station
ZTH	ZTH	GR	Airport	37.7508	20.8842	Europe/Athens	3.0	Zakynthos
ZUH	ZUH	CN	Airport	22.0067	113.3761	Asia/Shanghai	8.0	Zhuhai
ZWS	STR	DE	RailwayStation	48.7836	9.1814	Europe/Berlin	2.0	Stuttgart - Railway Station
ZYI	ZYI	CN	Airport	27.8111	107.2461	Asia/Urumqi	6.0	Zunyi Xinzhou
kzo	AKX	KZ	Airport	0	0	Asia/Qyzylorda	5.0	Kyzylorda
\.


--
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.cities (citycode, countrycode, name, utcoffset, timezoneid, airports) FROM stdin;
AAA	PF				
AAB	AU				
AAC	EG				
AAE	DZ				
AAF	US				
AAH	DE				
AAI	BR				
AAJ	SR				
AAK	KI				
AAL	DK				AAL
AAM	ZA				
AAN	AE				
AAO	VE				
AAQ	RU				
AAR	DK				AAR
AAS	ID				
AAT	CN				
AAU	WS				
AAV	PH				
AAX	BR				
AAY	YE				
ABA	RU				
ABD	IR				
ABE	US				ABE
ABF	KI				
ABG	AU				
ABH	AU				
ABI	US				
ABJ	CI				ABJ
ABK	ET				ABK
ABL	US				
ABM	AU				
ABN	SR				
ABO	CI				
ABP	PG				
ABQ	US				ABQ
ABR	US				
ABS	EG				
ABT	SA				
ABU	ID				
ABV	NG				ABV
ABW	PG				
ABX	AU				
ABY	US				
ABZ	GB				ABZ
ACA	MX				ACA
ACB	US				
ACC	GH				ACC
ACD	CO				
ACE	ES				ACE
ACH	CH				
ACI	GB				
ACK	US				ACK
ACL	CO				
ACM	CO				
ACN	MX				
ACO	CH				
ACR	CO				
ACS	RU				
ACT	US				ACT
ACU	PA				
ACV	US				ACV
ADA	TR				ADA
ADD	ET				ADD
ADE	YE				
ADF	TR				
ADG	US				
ADH	RU				
ADI	NA				
ADK	US				ADK
ADL	AU				ADL
ADM	US				
ADN	CO				
ADO	AU				
ADP	LK				
ADQ	US				ADQ
ADR	US				
ADT	US				
ADU	IR				
ADV	GB				
ADW	US				
ADY	ZA				
ADZ	CO				ADZ
AEA	KI				
AEG	ID				
AEH	TD				
AEK	PG				
AEL	US				
AEO	MR				
AER	RU				AER
AES	NO				AES
AET	US				
AEX	US				AEX
AEY	IS				
AFA	AR				
AFD	ZA				
AFI	CO				
AFL	BR				
AFN	US				
AFO	US				
AFR	PG				
AFT	SB				
AFY	TR				
AGA	MA				AGA
AGD	ID				
AGE	DE				
AGF	FR				
AGG	PG				
AGH	SE				AGH
AGI	SR				
AGJ	JP				
AGK	PG				
AGL	PG				
AGM	GL				
AGN	US				
AGO	US				
AGP	ES				AGP
AGQ	GR				
AGR	IN				
AGS	US				
AGT	PY				AGT
AGU	MX				AGU
AGV	VE				
AGW	AU				
AGX	IN				
AGY	AU				
AGZ	ZA				
AHB	SA				AHB
AHC	US				
AHH	US				
AHI	ID				
AHL	GY				
AHN	US				
AHO	IT				AHO
AHS	HN				
AHT	US				
AHU	MA				
AHY	MG				
AHZ	FR				
AIA	US				AIA
AIB	US				
AIC	MH				
AID	US				
AIE	PG				
AIF	BR				
AIG	CF				
AII	DJ				
AIK	US				
AIL	PA				
AIM	MH				
AIN	US				
AIO	US				
AIP	MH				
AIR	BR				
AIS	KI				
AIT	CK				
AIU	CK				
AIV	US				
AIY	US				ACY
AIZ	US				
AJA	FR				AJA
AJF	SA				
AJI	TR				AJI
AJJ	MR				
AJL	IN				AJL
AJN	KM				
AJO	YE				
AJR	SE				AJR
AJS	MX				
AJU	BR				AJU
AJY	NE				
AKA	CN				
AKB	US				
AKD	IN				
AKE	GA				
AKF	LY				
AKG	PG				
AKI	US				
AKJ	JP				AKJ
AKK	US				
AKL	NZ				AKL
AKM	TD				
AKN	US				
AKO	US				
AKP	US				
AKQ	ID				
AKR	NG				
AKS	SB				
AKT	CY				
AKU	CN				
AKV	CA				
AKX	KZ				CIT, GUW, SCO, kzo
AKY	MM				
ALA	KZ				ALA
ALB	US				ALB
ALC	ES				ALC
ALD	PE				
ALE	US				
ALF	NO				ALF
ALG	DZ				ALG
ALH	AU				
ALI	US				
ALJ	NA				
ALK	ET				
ALL	IT				
ALM	US				
ALN	US				
ALO	US				
ALP	SY				
ALQ	BR				
ALR	NZ				
ALS	US				ALS
ALT	BR				
ALU	SO				
ALW	US				ALW
ALX	US				
ALY	EG				HBE
ALZ	US				
AMA	US				AMA
AMB	MG				
AMC	TD				
AMD	IN				AMD
AME	MZ				
AMF	PG				
AMG	PG				
AMH	ET				AMH
AMI	ID				AMI
AMJ	BR				
AML	PA				
AMM	JO				AMM
AMN	US				
AMO	TD				
AMP	MG				
AMQ	ID				
AMR	MH				
AMS	NL				AMS
AMT	AU				
AMU	PG				
AMV	RU				
AMW	US				
AMX	AU				
AMY	MG				
AMZ	NZ				
ANA	US				
ANB	US				
ANC	US				ANC
AND	US				
ANE	FR				
ANF	CL				ANF
ANG	FR				
ANH	SB				
ANI	US				
ANJ	CG				
ANK	TR				ESB
ANL	AO				
ANM	MG				
ANN	US				
ANO	MZ				
ANP	US				
ANQ	US				
ANR	BE				
ANS	PE				
ANT	AT				
ANU	AG				ANU
ANV	US				
ANW	US				
ANX	NO				
ANY	US				
ANZ	AU				
AOA	PG				
AOB	PG				
AOC	DE				
AOD	TD				
AOG	CN				
AOH	US				
AOI	IT				AOI
AOJ	JP				AOJ
AOK	GR				AOK
AOL	AR				
AON	PG				
AOO	US				
AOR	MY				AOR
AOS	US				
AOU	LA				
APB	BO				
APC	US				
APE	PE				
APF	US				
APH	US				
API	CO				
APK	PF				
APL	MZ				APL
APN	US				
APO	CO				
APP	PG				
APQ	BR				
APR	PG				
APS	BR				
APT	US				
APU	BR				
APV	US				
APW	WS				APW
APX	BR				
APY	BR				
APZ	AR				
AQA	BR				
AQG	CN				
AQI	SA				
AQJ	JO				AQJ
AQM	BR				
AQP	PE				AQP
AQS	FJ				
AQY	US				
ARB	US				
ARC	US				
ARD	ID				
ARE	PR				
ARF	CO				
ARG	US				
ARH	RU				ARH
ARI	CL				ARI
ARJ	ID				
ARK	TZ				
ARL	BF				
ARM	AU				
ARO	CO				
ARP	PG				
ARQ	CO				
ARR	AR				
ARS	BR				
ART	US				
ARU	BR				
ARV	US				
ARW	RO				
ARX	US				
ARY	AU				
ARZ	AO				
ASA	ER				
ASB	TM				ASB
ASC	BO				
ASD	BS				
ASE	US				ASE
ASF	RU				ASF
ASG	NZ				
ASH	US				
ASI	SH				
ASJ	JP				
ASK	CI				
ASL	US				
ASM	ER				ASM
ASN	US				
ASO	ET				ASO
ASP	AU				
ASQ	US				
ASR	TR				ASR
AST	US				
ASU	PY				ASU
ASV	KE				
ASW	EG				ASW
ASX	US				
ASY	US				
ASZ	PG				
ATA	PE				
ATB	SD				
ATC	BS				
ATD	SB				
ATE	US				
ATF	EC				
ATG	PK				
ATH	GR				ATH
ATI	UY				
ATJ	MG				
ATK	US				
ATL	US				ATL
ATM	BR				
ATN	PG				
ATO	US				
ATP	PG				
ATQ	IN				ATQ
ATR	MR				
ATS	US				
ATT	US				
ATU	US				
ATV	TD				
ATW	US				ATW
ATX	KZ				
ATY	US				
ATZ	EG				ATZ
AUA	AW				AUA
AUB	BR				
AUC	CO				
AUD	AU				
AUE	EG				
AUG	US				AGS
AUH	AE				AUH
AUI	PG				
AUJ	PG				
AUK	US				
AUL	MH				
AUM	US				
AUN	US				
AUO	US				
AUP	PG				
AUQ	PF				
AUR	FR				
AUS	US				AUS
AUT	ID				
AUU	AU				
AUW	US				AUW, CWA
AUX	BR				
AUY	VU				
AUZ	US				
AVB	IT				
AVF	FR				
AVG	AU				
AVI	CU				
AVK	MN				
AVL	US				AVL
AVN	FR				
AVO	US				
AVP	US				AVP
AVU	SB				
AVV	AU				
AVX	US				
AWA	ET				AWA
AWB	PG				
AWD	VU				
AWE	GA				
AWH	ET				
AWK	UM				
AWM	US				
AWN	AU				
AWP	AU				
AWR	PG				
AWZ	IR				AWZ
AXA	AI				
AXC	AU				
AXD	GR				AXD
AXG	US				HDN
AXK	YE				
AXL	AU				
AXM	CO				AXM
AXN	US				
AXP	BS				
AXR	PF				
AXT	JP				AXT
AXU	ET				AXU
AXV	US				
AXX	US				
AYA	CO				
AYC	CO				
AYD	AU				
AYE	US				
AYG	CO				
AYH	GB				
AYI	CO				
AYK	KZ				
AYL	AU				
AYN	CN				
AYP	PE				
AYQ	AU				
AYR	AU				
AYS	US				
AYT	TR				AYT
AYU	PG				
AYW	ID				
AYZ	US				
AZB	PG				
AZD	IR				
AZG	MX				
AZN	UZ				
AZO	US				AZO
AZR	DZ				
AZS	DO				AZS
AZT	CO				
AZZ	AO				
BAA	PG				
BAC	CO				
BAE	FR				
BAF	US				
BAG	PH				
BAH	BH				BAH
BAI	CR				
BAJ	PG				
BAK	AZ				GYD
BAL	TR				BAL
BAM	US				
BAN	ZR				
BAO	TH				
BAP	PG				
BAQ	CO				BAQ
BAR	US				
BAS	SB				
BAT	BR				
BAU	BR				
BAV	CN				BAV
BAW	GA				
BAX	RU				
BAY	RO				
BAZ	BR				
BBA	CL				BBA
BBB	US				
BBC	US				
BBD	US				
BBE	AU				
BBF	US				
BBG	KI				
BBH	DE				
BBI	IN				BBI
BBJ	DE				
BBK	BW				BBK
BBL	IR				
BBM	KH				
BBN	MY				
BBO	SO				BBO
BBP	GB				
BBQ	AG				
BBR	GP				
BBS	GB				
BBT	CF				
BBV	CI				
BBW	US				
BBX	US				
BBY	CF				
BBZ	ZM				
BCA	CU				
BCB	US				
BCC	US				
BCD	PH				
BCE	US				
BCF	CF				
BCG	GY				
BCH	ID				
BCI	AU				
BCJ	US				
BCK	AU				
BCL	CR				
BCM	RO				
BCN	ES				BCN
BCO	ET				BCO
BCP	PG				
BCQ	LY				
BCR	BR				
BCS	US				
BCT	US				
BCU	NG				
BCX	RU				
BCY	ET				
BCZ	AU				
BDA	BM				BDA
BDB	AU				
BDC	BR				
BDD	AU				
BDE	US				
BDF	US				
BDG	US				
BDH	IR				
BDI	SC				
BDJ	ID				
BDK	CI				
BDM	TR				
BDN	PK				
BDO	ID				BDO
BDP	NP				
BDQ	IN				BDQ
BDR	US				
BDS	IT				BDS
BDT	ZR				
BDU	NO				
BDV	ZR				
BDW	AU				
BDX	US				
BDY	US				
BDZ	PG				
BEA	PG				
BEB	GB				
BED	US				
BEE	AU				
BEF	NI				
BEG	RS				BEG
BEH	US				
BEI	ET				
BEJ	ID				
BEK	IN				
BEL	BR				BEL
BEM	CF				
BEN	LY				
BEP	IN				
BER	DE				SXF, BER, TXL
BES	FR				
BET	US				BET
BEU	AU				
BEV	IL				
BEW	MZ				BEW
BEX	GB				
BEY	LB				BEY
BEZ	KI				
BFB	US				
BFC	AU				
BFD	US				
BFE	DE				
BFF	US				BFF
BFG	US				
BFJ	FJ				
BFL	US				BFL
BFN	ZA				BFN
BFO	ZW				
BFP	US				
BFR	US				
BFS	GB				BHD
BFT	US				
BFU	CN				
BFX	CM				
BGA	CO				BGA
BGB	GA				
BGC	PT				
BGD	US				
BGE	US				
BGF	CF				BGF
BGG	CI				BGG
BGH	MR				
BGI	BB				BGI
BGJ	IS				
BGK	BZ				
BGL	NP				
BGM	US				
BGN	DE				
BGO	NO				BGO
BGP	GA				
BGQ	US				
BGR	US				BGR
BGT	US				
BGU	CF				
BGV	BR				
BGW	IQ				BGW
BGX	BR				
BGZ	PT				
BHA	EC				
BHB	US				
BHE	NZ				BHE
BHF	CO				
BHG	HN				
BHH	SA				
BHI	AR				BHI
BHJ	IN				
BHK	UZ				
BHL	MX				
BHM	US				BHM
BHN	YE				
BHO	IN				BHO
BHP	NP				
BHQ	AU				
BHR	NP				
BHS	AU				
BHT	AU				
BHU	IN				
BHV	PK				
BHX	GB				BHX
BHY	CN				BHY
BHZ	BR				CNF
BIA	FR				BIA
BIB	SO				
BIC	US				
BID	US				
BIE	US				
BIG	US				
BIH	US				
BII	MH				
BIJ	PG				
BIK	ID				
BIL	US				BIL
BIM	BS				
BIN	AF				
BIO	ES				BIO
BIP	AU				
BIQ	FR				BIQ
BIR	NP				
BIS	US				BIS
BIT	NP				
BIU	IS				
BIV	CF				
BIW	AU				
BIX	US				
BIY	ZA				
BIZ	PG				
BJA	DZ				
BJC	US				
BJD	IS				
BJF	NO				
BJG	ID				
BJH	NP				
BJI	US				
BJJ	US				
BJK	ID				
BJL	GM				BJL
BJM	BI				BJM
BJN	MZ				
BJO	BO				
BJR	ET				BJR
BJS	CN				PEK
BJU	NP				
BJW	ID				
BJX	MX				BJX
BJZ	ES				
BKB	IN				
BKC	US				
BKD	US				
BKE	US				
BKF	US				
BKH	US				
BKI	MY				BKI
BKJ	GN				
BKK	TH				BKK, DMK
BKM	MY				
BKN	NE				
BKO	ML				BKO
BKP	AU				
BKQ	AU				
BKR	TD				
BKS	ID				
BKT	US				
BKU	MG				
BKW	US				
BKX	US				
BKY	ZR				
BKZ	TZ				
BLA	VE				BLA
BLB	PA				
BLC	CM				
BLD	US				
BLE	SE				
BLF	US				
BLG	MY				
BLH	US				
BLI	US				
BLJ	DZ				
BLK	GB				
BLL	DK				BLL
BLM	US				
BLN	AU				
BLO	IS				
BLP	PE				
BLQ	IT				BLQ
BLR	IN				BLR
BLS	AU				
BLT	AU				
BLU	US				
BLV	US				
BLW	US				
BLX	IT				
BLY	IE				
BLZ	MW				BLZ
BMB	ZR				
BMC	US				
BMD	MG				
BME	AU				
BMF	CF				
BMG	US				
BMH	PG				
BMI	US				
BMJ	GY				
BMK	DE				
BML	US				
BMM	GA				
BMN	IQ				
BMO	MM				
BMP	AU				
BMQ	KE				
BMR	DE				
BMS	BR				
BMU	ID				
BMV	VN				
BMW	DZ				
BMX	US				
BMY	NC				
BMZ	PG				
BNA	US				BNA
BNB	ZR				
BNC	ZR				
BND	IR				
BNE	AU				BNE
BNF	US				
BNG	US				
BNI	NG				
BNJ	DE				
BNK	AU				
BNL	US				
BNM	PG				
BNN	NO				
BNO	US				
BNP	PK				
BNQ	PH				
BNR	BF				
BNS	VE				
BNT	PG				
BNU	BR				
BNV	PG				
BNW	US				
BNX	BA				
BNY	SB				
BNZ	PG				
BOA	ZR				
BOB	PF				
BOC	PA				
BOD	FR				BOD
BOE	CG				
BOG	CO				BOG
BOH	GB				
BOI	US				BOI
BOJ	BG				BOJ
BOK	US				
BOL	GB				
BOM	IN				BOM
BON	AN				
BOO	NO				BOO
BOP	CF				
BOQ	PG				
BOR	FR				
BOS	US				BOS
BOT	PG				
BOU	FR				
BOV	PG				
BOW	US				
BOX	AU				
BOY	BF				
BOZ	CF				
BPA	US				
BPB	PG				
BPC	CM				
BPD	PG				
BPF	SB				
BPG	BR				
BPH	PH				
BPI	US				
BPN	ID				BPN
BPS	BR				BPS
BPT	US				BPT
BPU	JP				
BPY	MG				
BQA	PH				
BQE	GW				
BQH	GB				BQH
BQL	AU				
BQN	PR				BQN
BQO	CI				
BQQ	BR				
BQS	RU				
BQT	BY				
BQU	VC				
BQW	AU				
BRA	BR				
BRB	BR				
BRC	AR				BRC
BRD	US				
BRE	DE				BRE
BRF	GB				
BRG	US				
BRH	PG				
BRI	IT				BRI
BRJ	AU				
BRK	AU				
BRL	US				
BRM	VE				BRM
BRN	CH				BRN
BRO	US				BRO
BRP	PG				
BRQ	CZ				BRQ
BRR	GB				
BRS	GB				BRS
BRT	AU				
BRU	BE				BRU
BRV	DE				
BRW	US				BRW
BRX	DO				
BRY	US				
BRZ	CI				
BSA	SO				
BSB	BR				BSB
BSC	CO				
BSD	CN				
BSE	MY				
BSF	US				
BSG	GQ				
BSH	GB				
BSI	US				
BSJ	AU				
BSK	DZ				
BSL	CH				BSL
BSN	CF				
BSO	PH				
BSP	PG				
BSQ	US				
BSR	IQ				
BSS	BR				
BST	AF				
BSU	ZR				
BSW	US				
BSX	MM				
BSY	SO				
BSZ	US				
BTA	CM				
BTB	CG				
BTC	LK				
BTD	AU				
BTE	SL				
BTF	US				
BTG	CF				
BTH	ID				
BTI	US				
BTJ	ID				
BTK	RU				
BTL	US				
BTM	US				
BTN	US				
BTO	SR				
BTP	US				
BTQ	RW				
BTR	US				BTR
BTS	SK				
BTT	US				
BTU	MY				BTU
BTV	US				BTV
BTW	ID				
BTX	AU				
BTY	US				
BUA	PG				
BUB	US				
BUC	AU				
BUD	HU				BUD
BUE	AR				AEP, EZE
BUF	US				BUF
BUG	AO				
BUH	RO				OTP
BUI	ID				
BUJ	DZ				
BUK	YE				
BUL	PG				
BUM	US				
BUN	CO				
BUO	SO				
BUP	IN				
BUQ	ZW				BUQ
BUR	US				BUR
BUS	GE				BUS
BUT	GB				
BUU	CI				
BUV	UY				
BUW	ID				
BUX	ZR				
BUY	AU				
BUZ	IR				
BVA	FR				
BVB	BR				
BVC	CV				BVC
BVD	US				
BVE	FR				
BVF	FJ				
BVG	NO				
BVH	BR				
BVI	AU				
BVK	BO				
BVL	BO				
BVM	BR				
BVO	US				
BVP	PG				
BVR	CV				
BVS	BR				
BVU	US				
BVW	AU				
BVX	US				
BVY	US				
BVZ	AU				
BWA	NP				
BWB	AU				
BWC	US				
BWD	US				
BWE	DE				
BWF	GB				
BWG	US				
BWI	US				BWI
BWJ	PG				
BWK	HR				BWK
BWL	US				
BWM	US				
BWN	BN				BWN
BWO	RU				
BWP	PG				
BWQ	AU				
BWS	US				
BWT	AU				
BWU	AU				
BWY	GB				
BXA	US				
BXB	ID				
BXC	US				
BXD	ID				
BXE	SN				
BXH	KZ				
BXI	CI				
BXK	US				
BXL	FJ				
BXM	ID				
BXN	TR				BJV
BXS	US				
BXT	ID				
BXU	PH				
BXV	IS				
BXX	SO				
BYA	US				
BYB	OM				
BYC	BO				
BYD	YE				
BYG	US				
BYH	US				
BYI	US				
BYK	CI				
BYL	LR				
BYM	CU				
BYN	MN				
BYQ	ID				
BYR	DK				
BYS	US				
BYT	IE				
BYU	DE				
BYW	US				
BYX	AU				
BZA	NI				
BZC	BR				
BZD	AU				
BZE	BZ				BZE
BZG	PL				BZG
BZI	TR				
BZK	RU				
BZL	BD				
BZM	NL				
BZN	US				BZN
BZO	IT				
BZP	AU				
BZR	FR				
BZT	US				
BZU	ZR				
BZV	CG				BZV
BZY	MD				
BZZ	GB				
CAA	HN				
CAB	AO				
CAC	BR				
CAD	US				
CAE	US				CAE
CAF	BR				
CAG	IT				CAG
CAH	VN				
CAI	EG				CAI
CAJ	VE				
CAK	US				CAK
CAL	GB				
CAM	BO				
CAN	CN				CAN
CAO	US				
CAP	HT				
CAQ	CO				
CAR	US				
CAS	MA				CMN
CAT	BS				
CAU	BR				
CAV	AO				
CAW	BR				
CAX	GB				
CAY	GF				
CAZ	AU				
CBA	US				
CBB	BO				
CBC	AU				
CBD	IN				
CBE	US				
CBF	US				
CBG	GB				
CBH	DZ				
CBJ	DO				
CBK	US				
CBL	VE				
CBN	ID				
CBO	PH				
CBP	PT				
CBQ	NG				
CBR	AU				CBR
CBS	VE				
CBT	AO				
CBU	DE				
CBV	GT				
CBX	AU				
CBY	AU				
CBZ	US				
CCA	US				
CCB	US				
CCC	CU				
CCF	FR				
CCG	US				
CCH	CL				
CCI	BR				
CCJ	IN				CCJ
CCK	CC				
CCL	AU				
CCM	BR				
CCN	AF				
CCO	CO				
CCP	CL				CCP
CCQ	BR				
CCR	US				
CCS	VE				CCS
CCT	AR				
CCU	IN				CCU
CCV	VU				
CCW	AU				
CCX	BR				
CCY	US				
CCZ	BS				
CDA	AU				
CDB	US				
CDC	US				
CDE	PA				
CDF	IT				
CDH	US				
CDJ	BR				
CDK	US				
CDL	US				
CDN	US				
CDO	ZA				
CDP	IN				
CDQ	AU				
CDR	US				CDR
CDS	US				
CDU	AU				
CDV	US				CDV
CDW	US				
CDY	PH				
CEB	PH				CEB
CEC	US				CEC
CED	AU				
CEE	RU				
CEF	US				
CEG	GB				
CEI	TH				CEI
CEJ	UA				
CEK	RU				
CEL	BS				
CEM	US				
CEN	MX				
CEO	AO				
CEP	BO				
CEQ	FR				
CER	FR				
CES	AU				
CET	FR				
CEU	US				
CEV	US				
CEW	US				
CEX	US				
CEY	US				
CEZ	US				CEZ
CFA	US				
CFD	US				
CFE	FR				
CFF	AO				
CFG	CU				
CFH	AU				
CFI	AU				
CFN	IE				
CFO	BR				
CFP	AU				
CFR	FR				
CFS	AU				
CFT	US				
CFU	GR				CFU
CFV	US				
CGA	US				
CGB	BR				CGB
CGC	PG				
CGD	CN				
CGE	US				
CGG	PH				
CGI	US				
CGJ	ZM				
CGM	PH				
CGN	DE				CGN, QKL, QKU
CGO	CN				CGO
CGP	BD				
CGQ	CN				CGQ
CGR	BR				CGR
CGS	US				
CGT	MR				
CGU	VE				
CGV	AU				
CGY	PH				
CGZ	US				
CHA	US				CHA
CHB	PK				
CHC	NZ				CHC
CHD	US				
CHE	IE				
CHF	KR				
CHG	CN				CHG
CHH	PE				
CHI	US				ORD
CHJ	ZW				
CHK	US				
CHL	US				
CHM	PE				
CHN	KR				
CHO	US				CHO
CHP	US				
CHQ	GR				CHQ
CHR	FR				
CHS	US				CHS
CHT	NZ				
CHU	US				
CHV	PT				
CHW	CN				
CHX	PA				
CHY	SB				
CHZ	US				
CIC	US				CIC
CID	US				CID
CIE	AU				
CIF	CN				
CIG	US				
CIH	CN				
CIJ	BO				
CIK	US				
CIL	US				
CIM	CO				
CIN	US				
CIP	ZM				
CIQ	GT				
CIR	US				
CIS	KI				
CIT	KZ				
CIV	US				
CIW	VC				
CIX	PE				
CIY	IT				
CIZ	BR				
CJA	PE				
CJB	IN				CJB
CJC	CL				CJC
CJD	CO				
CJH	CA				
CJL	PK				
CJN	US				
CJS	MX				
CJU	KR				CJU
CKA	US				
CKB	US				CKB
CKC	UA				
CKD	US				
CKE	US				
CKG	CN				CKG
CKH	RU				
CKI	AU				
CKK	US				
CKM	US				
CKN	US				
CKO	BR				
CKR	US				
CKS	BR				
CKV	US				
CKX	US				
CKY	GN				CKY
CKZ	TR				
CLA	BD				
CLB	IE				
CLC	US				
CLD	US				CLD
CLE	US				CLE
CLG	US				
CLH	AU				
CLI	US				
CLJ	RO				CLJ
CLL	US				CLL
CLM	US				
CLN	BR				
CLO	CO				CLO
CLP	US				
CLQ	MX				
CLR	US				
CLS	US				
CLT	US				CLT
CLU	US				
CLV	BR				
CLX	AR				
CLY	FR				CLY
CLZ	VE				
CMA	AU				
CMB	LK				CMB
CMC	BR				
CMD	AU				
CME	MX				CME
CMF	FR				
CMG	BR				
CMH	US				CMH
CMI	US				CMI
CMJ	TW				
CMK	MW				
CML	AU				
CMM	GT				
CMO	SO				
CMP	BR				
CMQ	AU				
CMR	FR				
CMS	SO				
CMT	BR				
CMU	PG				
CMV	NZ				
CMW	CU				
CMX	US				CMX
CMY	US				
CMZ	MZ				
CNA	MX				
CNB	AU				
CNC	AU				
CND	RO				CND
CNE	US				
CNG	FR				
CNH	US				
CNI	CN				
CNJ	AU				
CNK	US				
CNL	DK				
CNM	US				
CNN	RU				
CNO	US				
CNP	GL				
CNQ	AR				
CNR	CL				
CNS	AU				CNS
CNT	AR				
CNU	US				
CNV	BR				
CNX	TH				CNX
CNY	US				CNY
CNZ	AO				
COA	US				
COB	AU				
COC	AR				
COD	US				COD
COE	US				
COG	CO				
COH	IN				
COJ	AU				
COK	IN				COK
COL	GB				
COM	US				
CON	US				
COO	BJ				COO
COP	US				
COQ	MN				
COR	AR				COR
COS	US				COS
COT	US				
COU	US				COU
COV	PT				
COW	CL				
COX	BS				
COY	AU				
COZ	DO				
CPA	LR				
CPB	CO				
CPC	AR				
CPD	AU				
CPE	MX				
CPF	ID				
CPG	AR				
CPH	DK				CPH
CPL	CO				
CPM	US				
CPN	PG				
CPO	CL				CPO
CPQ	BR				
CPR	US				CPR
CPT	ZA				CPT
CPU	BR				
CPV	BR				
CPX	PR				
CQF	FR				
CQP	AU				
CQS	BR				
CQT	CO				
CRA	RO				
CRB	AU				
CRC	CO				
CRD	AR				CRD
CRF	CF				
CRH	AU				
CRI	BS				
CRJ	AU				
CRK	PH				CRK
CRL	BE				
CRM	PH				
CRN	GB				
CRO	US				
CRP	US				CRP
CRQ	BR				
CRR	AR				
CRS	US				
CRT	US				
CRU	GD				
CRV	IT				
CRW	US				CRW
CRX	US				
CRY	AU				
CRZ	TM				
CSA	GB				
CSB	RO				
CSC	CR				
CSD	AU				
CSE	US				
CSF	FR				
CSI	AU				
CSJ	VN				
CSK	SN				
CSL	US				CSL, SBP
CSN	US				
CSP	US				
CSQ	US				
CSR	CO				
CSS	BR				
CST	FJ				
CSV	US				
CSW	BR				
CSX	CN				CSX
CSY	RU				
CTA	IT				CTA
CTB	US				
CTC	AR				
CTD	PA				
CTE	PA				
CTG	CO				CTG
CTH	US				
CTI	AO				
CTK	US				
CTL	AU				
CTM	MX				
CTN	AU				
CTO	US				
CTP	BR				
CTQ	BR				
CTR	AU				
CTT	FR				
CTU	CN				CTU
CTW	US				
CTX	US				
CTY	US				
CTZ	US				
CUA	MX				
CUC	CO				CUC
CUD	AU				
CUE	EC				
CUF	IT				
CUH	US				
CUI	CO				
CUJ	PH				
CUK	BZ				
CUL	MX				CUL
CUM	VE				CUM
CUN	MX				CUN
CUO	CO				
CUP	VE				
CUQ	AU				
CUR	CW				CUR
CUS	US				
CUT	AR				
CUU	MX				CUU
CUV	VE				
CUW	US				
CUY	AU				
CUZ	PE				CUZ
CVB	PG				
CVC	AU				
CVE	CO				
CVF	FR				
CVG	US				CVG
CVH	AR				
CVI	AR				
CVJ	MX				
CVL	PG				
CVM	MX				
CVN	US				
CVO	US				
CVQ	AU				
CVR	US				
CVT	GB				
CVU	PT				
CWB	BR				CWB
CWC	UA				
CWG	US				
CWI	US				
CWL	GB				CWL
CWP	PK				
CWR	AU				
CWS	US				
CWT	AU				
CWW	AU				
CXA	VE				
CXB	BD				
CXC	US				
CXF	US				
CXI	KI				
CXJ	BR				
CXL	US				
CXN	SO				
CXO	US				
CXP	ID				
CXQ	AU				
CXT	AU				
CXY	BS				
CYA	HT				
CYB	KY				
CYC	BZ				
CYE	US				
CYF	US				
CYG	AU				
CYI	TW				
CYL	HN				
CYM	US				
CYO	CU				
CYP	PH				
CYR	UY				
CYS	US				CYS
CYT	US				
CYU	PH				
CYX	RU				
CYZ	PH				
CZA	MX				
CZB	BR				
CZC	US				
CZE	VE				
CZF	US				
CZH	BZ				
CZJ	PA				
CZK	US				
CZL	DZ				
CZM	MX				CZM
CZN	US				
CZO	US				
CZP	US				
CZS	BR				
CZT	US				
CZU	CO				
CZW	PL				
CZX	CN				CZX
CZY	AU				
CZZ	US				
DAA	US				
DAB	US				DAB
DAC	BD				DAC
DAD	VN				DAD
DAE	IN				
DAF	PG				
DAG	US				
DAH	YE				
DAI	IN				
DAJ	AU				
DAM	SY				
DAN	US				
DAP	NP				
DAR	TZ				DAR
DAT	CN				DAT
DAU	PG				
DAV	PA				
DAX	CN				
DAY	US				DAY
DAZ	AF				
DBA	PK				
DBD	IN				
DBM	ET				
DBN	US				
DBO	AU				
DBP	PG				
DBQ	US				
DBS	US				
DBT	ET				
DBV	HR				DBV
DBY	AU				
DCI	IT				
DCK	US				
DCM	FR				
DCR	US				
DCT	BS				
DCU	US				
DCY	CN				
DDC	US				DDC
DDG	CN				DDG
DDI	AU				
DDM	PG				
DDN	AU				
DDP	PR				
DDU	PK				
DEB	HU				DEB
DEC	US				
DED	IN				
DEH	US				
DEI	SC				
DEL	IN				DEL
DEM	ET				
DEN	US				DEN
DEO	US				
DEP	IN				
DER	PG				
DES	SC				
DEZ	SY				
DFI	US				
DFP	AU				
DFW	US				DFW
DGA	BZ				
DGB	US				
DGC	ET				
DGE	AU				
DGG	PG				
DGN	US				
DGO	MX				DGO
DGP	LV				
DGR	NZ				
DGT	PH				
DGU	BF				
DGW	US				
DHA	SA				
DHD	AU				
DHI	NP				
DHL	YE				
DHM	IN				
DHN	US				
DHR	NL				
DHT	US				
DIB	IN				DIB
DIC	ZR				
DIE	MG				
DIJ	FR				
DIK	US				DIK
DIL	ID				
DIM	CI				
DIN	VN				
DIO	US				
DIP	BF				
DIQ	BR				
DIR	ET				DIR
DIS	CG				
DIU	IN				
DIV	CI				
DIY	TR				DIY
DJA	BJ				
DJB	ID				
DJE	TN				DJE
DJG	DZ				
DJJ	ID				
DJM	CG				
DJN	US				
DJO	CI				
DJU	IS				
DKI	AU				
DKK	US				
DKR	SN				DKR, DSS
DKS	RU				
DKV	AU				
DLA	CM				DLA
DLB	PG				
DLC	CN				DLC
DLD	NO				
DLE	FR				
DLG	US				
DLH	US				DLH
DLI	VN				
DLK	AU				
DLL	US				
DLM	TR				DLM
DLN	US				
DLO	US				
DLS	US				
DLV	AU				
DLY	VU				
DLZ	MN				
DMB	KZ				
DMD	AU				
DMM	SA				DMM
DMN	US				
DMO	US				
DMR	YE				
DMT	BR				
DMU	IN				DMU
DNB	AU				
DNC	CI				
DND	GB				
DNF	LY				
DNH	CN				DNH
DNI	SD				
DNK	UA				DNK
DNM	AU				
DNN	US				
DNO	BR				
DNP	NP				
DNQ	AU				
DNR	FR				
DNS	US				
DNU	PG				
DNV	US				
DNX	SD				
DNZ	TR				DNZ
DOA	MG				
DOB	ID				
DOC	GB				
DOD	TZ				
DOE	SR				
DOF	US				
DOG	SD				
DOH	QA				DOH
DOI	PG				
DOK	UA				DOK
DOL	FR				
DOM	DM				
DON	GT				
DOO	PG				
DOP	NP				
DOR	BF				
DOS	PG				
DOU	BR				
DOV	US				
DOX	AU				
DPE	FR				
DPG	US				
DPK	US				
DPL	PH				
DPO	AU				
DPS	ID				DPS
DPU	PG				
DQA	CN				DQA
DRA	US				
DRB	AU				
DRC	AO				
DRE	US				
DRF	US				
DRG	US				
DRH	ID				
DRI	US				
DRJ	SR				
DRM	GR				
DRN	AU				
DRO	US				DRO
DRR	AU				
DRS	DE				DRS
DRT	US				DRT
DRU	US				
DRW	AU				DRW
DSC	CM				
DSD	GP				
DSE	ET				DSE
DSG	PH				
DSI	US				
DSK	PK				
DSL	SL				
DSM	US				DSM
DSN	CN				DSN
DSV	US				
DTA	US				
DTD	ID				
DTE	PH				
DTH	US				
DTL	US				
DTM	DE				DTM, DTZ
DTR	US				
DTT	US				DTW
DUA	US				
DUB	IE				DUB
DUC	US				
DUD	NZ				DUD
DUE	AO				
DUF	US				
DUG	US				
DUI	DE				
DUJ	US				
DUK	ZA				
DUM	ID				
DUN	GL				
DUQ	CA				
DUR	ZA				DUR
DUS	DE				DUS, NRN, QDU
DUT	US				
DVA	RO				DVA
DVL	US				DVL
DVN	US				
DVO	PH				DVO
DVP	AU				
DVR	AU				
DWA	MW				
DWB	MG				
DXA	FR				
DXB	AE				DXB
DXD	AU				
DXR	US				
DYA	AU				
DYG	CN				DYG
DYL	US				
DYM	AU				
DYR	RU				
DYU	TJ				DYU
DYW	AU				
DZA	YT				
DZI	CO				
DZN	KZ				
DZO	UY				
DZU	CN				DAX
EAA	US				
EAB	YE				
EAE	VU				
EAM	SA				
EAN	US				
EAR	US				EAR
EAS	ES				
EAT	US				EAT
EAU	US				EAU
EBA	IT				
EBB	UG				EBB
EBD	SD				
EBG	CO				
EBJ	DK				EBJ
EBL	IQ				EBL
EBM	TN				
EBN	MH				
EBO	MH				
EBS	US				
EBU	FR				
EBW	CM				
ECA	US				ECA
ECG	US				
ECH	AU				
ECN	CY				
ECO	CO				
ECP	US				ECP
ECR	CO				
ECS	US				
EDA	US				
EDB	SD				
EDD	AU				
EDE	US				
EDG	US				
EDI	GB				EDI
EDK	US				
EDL	KE				
EDM	FR				
EDO	TR				EDO
EDQ	HN				
EDR	AU				
EED	US				
EEK	US				
EEN	US				
EFB	US				
EFG	PG				
EFK	US				
EFL	GR				EFL
EFO	US				
EFW	US				
EGA	PG				
EGC	FR				
EGE	US				EGE
EGL	ET				
EGM	SB				
EGN	SD				
EGO	RU				EGO
EGP	US				
EGS	IS				
EGV	US				
EGX	US				
EHL	AR				
EHM	US				
EHT	US				
EIA	PG				
EIE	RU				
EIH	AU				
EIN	NL				
EIS	VG				
EIY	IL				
EIZ	DE				
EJA	CO				EJA
EJH	SA				
EJQ	CN				WDS
EKA	US				
EKB	KZ				
EKD	AU				
EKE	GY				
EKI	US				
EKN	US				
EKO	US				
EKT	SE				
EKX	US				
ELA	US				
ELB	CO				
ELC	AU				
ELD	US				
ELE	PA				
ELF	SD				
ELG	DZ				
ELH	BS				
ELI	US				
ELJ	CO				
ELK	US				
ELL	ZA				
ELM	US				ELM
ELN	US				
ELO	AR				
ELP	US				ELP
ELQ	SA				
ELR	ID				
ELS	ZA				ELS
ELT	EG				
ELU	DZ				
ELV	US				
ELW	US				
ELY	US				
ELZ	US				
EMA	GB				EMA
EMD	AU				
EME	DE				
EMG	ZA				
EMI	PG				
EMK	US				
EMM	US				
EMN	MR				
EMO	PG				
EMP	US				
EMS	PG				
EMT	US				
EMX	AR				
EMY	EG				
ENA	US				
ENB	AU				
ENE	ID				
ENF	FI				
ENH	CN				
ENI	PH				
ENJ	GT				
ENK	GB				
ENL	US				
ENN	US				
ENO	PY				
ENS	NL				
ENT	MH				
ENU	NG				ENU
ENV	US				
ENW	US				
ENY	CN				
EOI	GB				
EOK	US				
EOR	VE				
EOS	US				
EOZ	VE				
EPG	US				
EPH	US				
EPI	VU				
EPK	CY				
EPL	FR				
EPN	CG				
EPR	AU				
EPT	PG				
EQS	AR				
ERA	SO				
ERB	AU				
ERC	TR				ERC
ERD	UA				
ERE	PG				
ERF	DE				
ERH	MA				
ERI	US				ERI
ERM	BR				
ERN	BR				
ERO	US				
ERR	US				
ERT	MN				
ERU	PG				
ERV	US				
ERZ	TR				ERZ
ESA	PG				
ESC	US				
ESD	US				
ESE	MX				
ESF	US				
ESG	PY				
ESH	GB				
ESI	BR				
ESK	TR				
ESL	RU				
ESM	EC				
ESN	US				
ESO	US				
ESP	US				
ESR	CL				
ESS	DE				
EST	US				
ESW	US				
ETB	US				
ETD	AU				
ETE	ET				
ETH	IL				
ETN	US				
ETS	US				
ETZ	FR				
EUA	TO				
EUC	AU				
EUE	US				
EUF	US				
EUG	US				EUG
EUM	DE				
EUN	MA				
EUO	CO				
EUX	AN				
EVA	US				
EVD	AU				
EVE	NO				EVE
EVG	SE				
EVH	AU				
EVM	US				
EVN	AM				EVN
EVV	US				EVV
EVW	US				
EVX	FR				
EWB	US				
EWE	ID				
EWI	ID				
EWK	US				
EWN	US				EWN
EWO	CG				
EWY	GB				
EXI	US				
EXM	AU				
EXT	GB				
EYL	ML				
EYP	CO				
EYR	US				
EYS	KE				
EYW	US				EYW
EZS	TR				EZS
FAA	GN				
FAB	GB				
FAC	PF				
FAE	FO				FAE
FAF	US				
FAG	IS				
FAH	AF				
FAI	US				FAI
FAJ	PR				
FAK	US				
FAL	US				
FAM	US				
FAN	NO				
FAO	PT				FAO
FAR	US				FAR
FAS	IS				
FAT	US				FAT
FAV	PF				
FAY	US				FAY
FBD	AF				
FBE	BR				
FBL	US				
FBM	CD				FBM
FBR	US				
FBY	US				
FCA	US				FCA
FCB	ZA				
FCY	US				
FDE	NO				
FDF	MQ				
FDH	DE				FDH
FDK	US				
FDR	US				
FDU	ZR				
FDY	US				
FEA	GB				
FEB	NP				
FEG	UZ				
FEK	CI				
FEL	DE				
FEN	BR				
FEP	US				
FER	KE				
FET	US				
FEZ	MA				FEZ
FFA	US				
FFD	GB				
FFL	US				
FFM	US				
FFT	US				
FFU	CL				
FGD	MR				
FGL	NZ				
FGU	PF				
FHU	US				
FHZ	PF				
FIC	US				
FID	US				
FIE	GB				
FIG	GN				
FIH	CD				FIH
FIK	AU				
FIL	US				
FIN	PG				
FIV	US				
FIZ	AU				
FJR	AE				
FKB	DE				FKB, KJR
FKH	GB				
FKI	ZR				
FKJ	JP				
FKL	US				
FKN	US				
FKQ	ID				
FKS	JP				FKS
FLA	CO				
FLB	BR				
FLC	AU				
FLD	US				
FLF	DE				
FLG	US				
FLH	GB				
FLI	IS				
FLJ	US				
FLL	US				FLL
FLM	PY				
FLN	BR				FLN
FLO	US				FLO
FLP	US				
FLR	IT				FLR
FLS	AU				
FLT	US				
FLW	PT				
FLY	AU				
FMA	AR				
FMC	US				
FME	US				
FMG	CR				
FMH	US				
FMI	ZR				
FMM	DE				FMM
FMN	US				FMN
FMO	DE				FMO
FMS	US				
FMY	US				FMY, RSW
FNA	SL				FNA
FNC	PT				FNC
FNE	PG				
FNG	BF				
FNH	ET				
FNI	FR				
FNJ	KP				FNJ
FNK	US				
FNL	US				
FNR	US				
FNT	US				FNT
FOA	GB				
FOB	US				
FOC	CN				FOC
FOD	US				
FOG	IT				
FOK	US				
FOM	CM				
FOO	ID				
FOP	US				
FOR	BR				FOR
FOS	AU				
FOT	AU				
FOU	GA				
FOX	US				
FOY	LR				
FPO	BS				
FPR	US				
FPY	US				
FRA	DE				FRA
FRB	AU				
FRC	BR				
FRD	US				
FRE	SB				
FRG	US				
FRH	US				
FRI	US				
FRJ	FR				
FRK	SC				
FRL	IT				
FRM	US				
FRO	NO				
FRP	US				
FRQ	PG				
FRR	US				
FRS	GT				FRS
FRT	CL				
FRU	KG				FRU
FRW	BW				FRW
FRY	US				
FRZ	DE				
FSC	FR				FSC
FSD	US				FSD
FSI	US				
FSK	US				
FSL	AU				
FSM	US				
FSN	US				
FSP	PM				
FST	US				
FSU	US				
FSZ	JP				FSZ
FTA	VU				
FTE	AR				FTE
FTI	AS				
FTK	US				
FTL	US				
FTU	MG				
FTX	CG				
FUB	PG				
FUE	ES				FUE
FUG	CN				
FUJ	JP				FUJ
FUK	JP				FUK
FUL	US				
FUM	PG				
FUN	TV				
FUO	CN				
FUT	WF				
FWA	US				FWA
FWL	US				
FWM	GB				
FXM	US				
FXO	MZ				
FXY	US				
FYM	US				
FYN	CN				
FYT	TD				
FYU	US				
FYV	US				FYV, XNA
FZO	GB				
GAA	CO				
GAB	US				
GAC	HN				
GAD	US				
GAE	TN				
GAF	TN				
GAG	US				
GAH	AU				
GAI	US				
GAJ	JP				
GAK	US				
GAL	US				
GAM	US				
GAO	CU				
GAP	PG				
GAQ	ML				
GAR	PG				
GAS	KE				
GAT	FR				
GAU	IN				GAU
GAV	ID				
GAW	MM				
GAX	GA				
GAY	IN				GAY
GAZ	PG				
GBA	VU				
GBB	DZ				
GBC	PG				
GBD	US				
GBE	BW				GBE
GBF	PG				
GBG	US				
GBH	US				
GBI	BS				
GBJ	GP				
GBK	SL				
GBL	AU				
GBM	SO				
GBP	AU				
GBR	US				
GBS	NZ				
GBU	SD				
GBV	AU				
GBZ	NZ				
GCA	CO				
GCC	US				GCC
GCI	GB				GCI
GCK	US				GCK
GCM	KY				GCM
GCN	US				FLG
GCY	US				
GDA	CF				
GDD	AU				
GDE	ET				GDE
GDG	RU				
GDH	US				
GDI	CF				
GDJ	ZR				
GDL	MX				GDL
GDM	US				
GDN	PL				GDN
GDO	VE				
GDP	BR				
GDQ	ET				GDQ
GDT	TC				
GDV	US				
GDW	US				
GDX	RU				
GDZ	RU				
GEB	ID				
GEC	CY				
GED	US				
GEE	AU				
GEF	SB				
GEG	US				GEG
GEI	PG				
GEK	US				
GEL	BR				
GEO	GY				GEO
GER	CU				
GES	PH				
GET	AU				
GEV	SE				
GEW	PG				
GEX	AU				
GEY	US				
GFB	US				
GFD	US				
GFE	AU				
GFF	AU				
GFK	US				
GFL	US				
GFN	AU				
GFO	GY				
GFR	FR				
GFY	NA				
GGC	AO				
GGD	AU				
GGE	US				
GGG	US				
GGL	CO				
GGN	CI				
GGO	CI				
GGR	SO				
GGS	AR				
GGT	BS				
GGW	US				
GHA	DZ				
GHB	BS				
GHC	BS				
GHD	ET				
GHE	PA				
GHK	IL				
GHM	US				
GHN	CN				
GHT	LY				
GHU	AR				
GIB	GI				
GIC	AU				
GID	BI				
GIF	US				
GII	GN				
GIL	PK				
GIM	GA				
GIR	CO				
GIS	NZ				GIS
GIT	TZ				
GIY	ZA				
GIZ	SA				
GJA	HN				
GJL	DZ				
GJM	BR				
GJR	IS				
GJT	US				GJT
GKA	PG				
GKE	DE				
GKH	NP				
GKL	AU				
GKN	US				
GKO	GA				
GKT	US				
GLA	GB				GLA
GLC	ET				
GLD	US				
GLE	US				
GLF	CR				
GLG	AU				
GLH	US				
GLI	AU				
GLK	SO				
GLL	NO				
GLM	AU				
GLN	MA				
GLO	GB				
GLP	PG				
GLQ	US				
GLR	US				
GLS	US				
GLT	AU				
GLV	US				
GLW	US				
GLX	ID				
GLY	AU				
GLZ	NL				
GMA	ZR				
GMB	ET				GMB
GMC	CO				
GME	BY				
GMI	PG				
GMM	CG				
GMN	NZ				
GMR	PF				
GMT	US				
GMY	DE				
GNA	BY				
GNB	FR				
GND	GD				GND
GNE	BE				
GNG	US				
GNI	TW				
GNM	BR				
GNN	ET				
GNR	AR				
GNS	ID				
GNT	US				
GNU	US				
GNV	US				GNV
GNZ	BW				
GOA	IT				GOA
GOB	ET				GOB
GOC	PG				
GOE	PG				
GOH	GL				
GOI	IN				GOI
GOJ	RU				GOJ
GOK	US				
GOL	US				
GOM	CG				GOM
GON	US				
GOO	AU				
GOP	IN				
GOQ	CN				
GOR	ET				
GOS	AU				
GOT	SE				GOT
GOU	CM				
GOV	AU				
GOW	CA				
GOY	LK				
GOZ	BG				
GPA	GR				GPA
GPB	BR				
GPI	CO				
GPL	CR				
GPN	AU				
GPO	AR				
GPS	EC				GPS
GPT	US				GPT
GPZ	US				
GQJ	GB				
GQQ	US				
GRA	CO				
GRB	US				GRB
GRC	LR				
GRD	US				
GRE	US				
GRG	AF				
GRH	PG				
GRI	US				GRI
GRJ	ZA				GRJ
GRL	PG				
GRM	US				
GRN	US				
GRO	ES				GRO
GRP	BR				
GRQ	NL				GRQ
GRR	US				GRR
GRS	IT				
GRT	PK				
GRV	RU				
GRW	PT				
GRX	ES				
GRY	IS				
GRZ	AT				GRZ
GSA	MY				
GSB	US				
GSC	AU				
GSH	US				
GSI	SB				
GSN	AU				
GSO	US				GSO
GSP	US				GSP
GSR	SO				
GSS	ZA				
GST	US				
GSU	SD				
GTA	SB				
GTB	MY				
GTC	BS				
GTE	AU				
GTF	US				GTF
GTG	US				
GTI	DE				
GTK	MY				
GTO	ID				
GTS	AU				
GTT	AU				
GTW	CZ				
GTY	US				
GUA	GT				GUA
GUB	MX				
GUC	US				GUC
GUD	ML				
GUE	PG				
GUF	US				
GUG	PG				
GUH	AU				
GUI	VE				
GUJ	BR				
GUL	AU				
GUM	GU				GUM
GUO	HN				
GUP	US				
GUQ	VE				
GUR	PG				
GUS	US				
GUT	DE				
GUU	IS				
GUV	PG				
GUW	KZ				
GUX	IN				
GUY	US				
GVA	CH				GVA
GVE	US				
GVI	PG				
GVL	US				
GVP	AU				
GVR	BR				
GVT	US				
GVW	US				
GVX	SE				
GWA	MM				
GWD	PK				
GWE	ZW				
GWL	IN				GWL
GWN	PG				
GWO	US				
GWS	US				
GWT	DE				GWT
GWV	US				
GWY	IE				
GXF	YE				
GXG	AO				
GXQ	CL				
GXX	CM				
GXY	US				
GYA	BO				
GYE	EC				GYE
GYI	RW				
GYL	AU				
GYM	MX				
GYN	BR				GYN
GYP	AU				
GYR	US				
GZI	AF				
GZM	MT				
GZO	SB				
GZP	TR				GZP
GZT	TR				GZT
HAA	NO				
HAB	US				
HAC	JP				HAC
HAD	SE				
HAE	US				
HAF	US				
HAG	NL				
HAI	US				
HAJ	DE				HAJ
HAK	CN				HAK
HAL	NA				
HAM	DE				HAM
HAN	VN				HAN
HAO	US				
HAP	AU				
HAR	US				HAR, MDT
HAS	SA				
HAT	AU				
HAU	NO				HAU
HAV	CU				HAV
HAW	GB				
HAY	US				
HAZ	PG				
HBA	AU				HBA
HBC	US				
HBG	US				
HBH	US				
HBI	BS				
HBL	ZA				
HBN	VN				
HBO	US				
HBR	US				
HBT	SA				
HBX	IN				
HCA	US				
HCB	US				
HCC	US				
HCM	SO				
HCQ	AU				
HCR	US				
HCW	US				
HDA	US				
HDB	DE				HDB
HDD	PK				
HDE	US				
HDF	DE				HDF
HDH	US				
HDM	IR				
HDN	US				
HDS	ZA				HDS
HDY	TH				HDY
HEA	AF				
HEB	MM				
HED	US				
HEE	US				
HEH	MM				
HEI	DE				
HEK	CN				
HEL	FI				HEL
HEN	GB				
HEO	PG				
HER	GR				HER
HES	US				
HET	CN				HET
HEZ	US				
HFA	IL				
HFD	US				BDL, HRL
HFE	CN				HFE
HFF	US				
HFN	IS				
HFS	SE				
HFT	NO				
HGA	SO				HGA
HGD	AU				
HGH	CN				HGH
HGL	DE				
HGN	TH				
HGO	CI				
HGR	US				
HGT	US				
HGU	PG				
HGZ	US				
HHA	CN				
HHE	JP				
HHH	US				HHH
HHI	US				
HHN	DE				
HHQ	TH				
HHR	US				
HHZ	PF				
HIB	US				
HID	AU				
HIE	US				
HIG	AU				
HIH	AU				
HII	US				
HIJ	JP				HIJ
HIL	ET				HIL
HIN	KR				HIN
HIO	US				
HIP	AU				
HIR	SB				
HIS	AU				
HIT	PG				
HIW	JP				
HIX	PF				
HJR	IN				
HJT	MN				
HKB	US				
HKD	JP				HKD
HKG	HK				HKG
HKK	NZ				
HKN	PG				
HKT	TH				HKT
HKV	BG				
HKY	US				
HLA	ZA				
HLB	US				
HLC	US				
HLD	CN				HLD
HLF	SE				
HLG	US				
HLH	CN				HLH
HLI	US				
HLJ	LT				
HLL	AU				
HLM	US				
HLN	US				HLN
HLS	AU				
HLT	AU				
HLU	NC				
HLV	AU				
HLW	ZA				
HLY	GB				
HLZ	NZ				
HME	DZ				
HMG	AU				
HMI	CN				
HMJ	UA				
HMO	MX				HMO
HMR	NO				
HMS	US				
HMT	US				
HMV	SE				
HNA	JP				
HNB	US				
HNC	US				
HNE	US				
HNG	NC				
HNH	US				
HNI	PG				
HNK	AU				
HNL	US				HNL
HNM	US				
HNN	PG				
HNO	ME				
HNS	US				
HNX	US				
HNY	CN				
HOA	KE				
HOB	US				
HOC	PG				
HOD	YE				
HOE	LA				
HOF	SA				
HOG	CU				HOG
HOH	AT				
HOI	PF				
HOK	AU				
HOL	US				
HOM	US				
HON	US				
HOO	VN				
HOP	US				
HOQ	DE				
HOR	PT				
HOS	AR				
HOT	US				
HOU	US				IAH
HOV	NO				HOV
HOW	PA				
HOX	MM				
HOY	GB				
HPA	TO				
HPB	US				
HPE	AU				
HPH	VN				
HPN	US				HPN
HPT	US				
HPY	US				
HQM	US				
HRA	PK				
HRB	CN				HRB
HRE	ZW				HRE
HRG	EG				HRG
HRJ	NP				
HRK	UA				HRK
HRL	US				
HRM	DZ				
HRN	AU				
HRO	US				
HRR	CO				
HRS	ZA				
HRY	AU				
HSB	US				
HSC	CN				
HSG	JP				HSG
HSI	US				
HSL	US				
HSM	AU				
HSP	US				
HSS	IN				
HST	US				
HSV	US				HSV
HTA	RU				
HTB	GP				
HTF	GB				
HTG	RU				
HTH	US				
HTI	AU				
HTL	US				
HTN	CN				
HTO	US				
HTR	JP				
HTS	US				HTS
HTU	AU				
HTV	US				
HTW	US				
HTY	TR				HTY
HTZ	CO				
HUB	AU				
HUC	PR				
HUD	US				
HUE	ET				HUE
HUF	US				
HUG	GT				
HUH	PF				
HUI	VN				
HUJ	US				
HUK	BW				
HUL	US				
HUM	US				
HUN	TW				
HUQ	LY				
HUS	US				
HUT	US				
HUU	PE				
HUV	SE				
HUX	MX				HUX
HUY	GB				
HUZ	CN				
HVA	MG				
HVB	AU				
HVD	MN				
HVE	US				
HVG	NO				
HVK	IS				
HVM	IS				
HVN	US				
HVR	US				
HVS	US				
HWA	PG				
HWD	US				
HWI	US				
HWK	AU				
HWN	ZW				
HWO	US				
HXX	AU				
HYA	US				
HYC	GB				
HYD	IN				HYD
HYF	PG				
HYG	US				
HYL	US				
HYN	CN				HYN
HYR	US				
HYS	US				HYS
HYV	FI				
HZB	FR				
HZG	CN				
HZK	IS				
HZL	US				
HZV	ZA				
IAA	RU				
IAG	US				
IAM	DZ				
IAN	US				
IAQ	IR				
IAR	RU				
IAS	RO				IAS
IAU	PG				
IBA	NG				
IBE	CO				
IBI	PG				
IBO	MZ				
IBP	PE				
IBZ	ES				IBZ
ICA	VE				
ICI	FJ				
ICK	SR				
ICL	US				
ICO	PH				
ICR	CU				
ICT	US				ICT
ICY	US				
IDA	US				IDA
IDB	SE				
IDF	ZR				
IDG	US				
IDI	US				
IDK	AU				
IDN	PG				
IDO	BR				
IDP	US				
IDR	IN				IDR
IDY	FR				
IEG	PL				IEG
IEJ	JP				
IEV	UA				IEV, KBP
IFA	US				
IFF	AU				
IFJ	IS				
IFL	AU				
IFN	IR				IFN
IFO	UA				
IFP	US				
IGA	BS				
IGB	AR				
IGD	TR				IGD
IGE	GA				
IGG	US				
IGH	AU				
IGM	US				
IGN	PH				
IGO	CO				
IGR	AR				IGR
IGU	BR				IGU
IHA	JP				
IHN	YE				
IHO	MG				
IHU	PG				
IIA	IE				
IIN	JP				
IIS	PG				
IJK	RU				
IJU	BR				
IJX	US				
IKB	US				
IKI	JP				
IKK	US				
IKL	ZR				
IKO	US				
IKP	AU				
IKS	RU				
IKT	RU				
ILA	ID				
ILB	BR				
ILC	PE				
ILE	US				ILE
ILF	CA				
ILG	US				
ILH	DE				
ILI	US				
ILK	MG				
ILL	US				
ILM	US				ILM
ILN	US				
ILO	PH				
ILP	NC				
ILR	NG				
ILU	KE				
ILX	PG				
ILY	GB				
ILZ	SK				
IMA	PG				
IMB	GY				
IMD	PG				
IMF	IN				IMF
IMG	MZ				
IMI	MH				
IMK	NP				
IML	US				
IMM	US				
IMN	PG				
IMO	CF				
IMP	BR				
IMT	US				
IMZ	AF				
INA	RU				
INB	BZ				
INC	CN				INC
IND	US				IND
INE	MZ				
INF	DZ				
ING	AR				
INH	MZ				
INI	RS				INI
INJ	AU				
INK	US				
INL	US				
INM	AU				
INN	AT				INN
INO	ZR				
INQ	IE				
INS	US				
INT	US				
INU	NR				
INV	GB				
INW	US				
INX	ID				
INY	ZA				
INZ	DZ				
IOA	GR				IOA
IOK	PG				
IOM	GB				
ION	CG				
IOP	PG				
IOR	IE				
IOS	BR				IOS
IOU	NC				
IOW	US				
IPA	VU				
IPC	CL				
IPE	PH				
IPG	BR				
IPH	MY				
IPI	CO				
IPL	US				IPL
IPN	BR				
IPT	US				
IPU	BR				
IPW	GB				
IQM	CN				
IQN	CN				
IQQ	CL				IQQ
IQT	PE				
IRA	SB				
IRB	US				
IRC	US				
IRD	BD				
IRE	BR				
IRG	AU				
IRI	TZ				
IRJ	AR				
IRK	US				
IRN	HN				
IRO	CF				
IRP	ZR				
IRS	US				
ISA	AU				
ISB	PK				ISB
ISC	GB				
ISD	CO				
ISE	TR				ISE
ISG	JP				ISG
ISH	IT				
ISI	AU				
ISJ	MX				
ISK	IN				
ISL	US				
ISM	US				
ISN	US				ISN
ISO	US				
ISP	US				
ISQ	US				
ISS	US				
IST	TR				ISL, IST, SAW
ISU	IQ				ISU
ISW	US				
ITA	BR				
ITB	BR				
ITE	BR				
ITH	US				ITH
ITI	BR				
ITK	PG				
ITN	BR				
ITO	US				ITO
ITQ	BR				
IUE	NU				
IUL	ID				
IUM	CA				
IUS	PG				
IVA	MG				
IVC	NZ				IVC
IVG	ME				
IVH	US				
IVL	FI				IVL
IVO	CO				
IVR	AU				
IVW	AU				
IWA	RU				
IWD	US				
IWJ	JP				IWJ
IWK	JP				IWK
IWO	JP				
IXA	IN				IXA
IXB	IN				IXB
IXC	IN				IXC
IXD	IN				IXD
IXE	IN				IXE
IXG	IN				
IXH	IN				
IXI	IN				
IXJ	IN				IXJ
IXK	IN				
IXL	IN				IXL
IXM	IN				IXM
IXN	IN				
IXP	IN				
IXQ	IN				
IXR	IN				IXR
IXS	IN				IXS
IXT	IN				
IXU	IN				IXU
IXV	IN				
IXW	IN				
IXY	IN				
IXZ	IN				IXZ
IYK	US				
IZM	TR				ADB
IZO	JP				
IZT	MX				
JAA	AF				
JAB	AU				
JAC	US				JAC
JAD	AU				
JAF	LK				
JAG	PK				
JAH	FR				
JAI	IN				JAI
JAK	HT				
JAL	MX				
JAM	BG				
JAN	US				JAN
JAQ	PG				
JAS	US				
JAT	MH				
JAU	PE				
JAV	GL				
JAX	US				JAX
JBK	US				
JBR	US				
JBS	US				
JCB	BR				
JCH	GL				
JCK	AU				
JCM	BR				
JCN	KR				
JCR	BR				
JCT	US				
JCY	US				
JDA	US				
JDF	BR				
JDH	IN				JDH
JDN	US				
JDO	BR				
JDY	US				
JDZ	CN				JDZ
JED	SA				JED
JEE	HT				
JEF	US				
JEG	GL				
JEJ	MH				
JEM	US				
JEQ	BR				
JER	GB				JER
JEV	FR				
JFM	AU				
JFN	US				
JFR	GL				
JGA	IN				JGA
JGB	IN				
JGE	KR				
JGN	CN				
JGO	GL				
JGR	GL				
JHB	MY				JHB
JHG	CN				
JHM	US				JHM
JHQ	AU				
JHS	GL				
JHW	US				
JIA	BR				
JIB	DJ				JIB
JIJ	ET				JIJ
JIL	CN				
JIM	ET				JIM
JIN	UG				
JIP	EC				
JIR	NP				
JIU	CN				
JIW	PK				
JJI	PE				
JJN	CN				JJN
JJU	GL				
JKG	SE				JKG
JKH	GR				JKH
JKR	NP				
JKT	ID				CGK
JKV	US				
JLA	US				
JLD	SE				
JLH	US				
JLN	US				
JLO	IT				
JLP	FR				
JLR	IN				JLR
JLS	BR				
JMB	AO				
JMC	US				
JMH	US				
JMK	GR				JMK
JMO	NP				
JMS	US				JMS
JMU	CN				JMU
JNA	BR				
JNB	ZA				JNB
JNG	CN				
JNI	AR				
JNN	GL				
JNP	US				
JNS	GL				
JNU	US				
JNX	GR				
JNZ	CN				
JOE	FI				
JOG	ID				
JOH	ZA				
JOI	BR				JOI
JOK	RU				JOK
JOL	PH				
JOM	TZ				
JON	UM				
JOP	PG				
JOR	US				
JOS	NG				
JOT	US				
JPA	BR				JPA
JPD	US				
JPR	BR				
JQE	PA				
JRH	IN				JRH
JRK	GL				
JRN	BR				
JRO	TZ				JRO
JRS	IL				
JSA	IN				
JSD	US				
JSH	GR				JSH
JSI	GR				JSI
JSM	AR				
JSO	SE				
JSR	BD				
JSS	GR				
JST	US				
JSU	GL				
JSY	GR				
JTO	US				
JTR	GR				JTR
JTY	GR				
JUA	BR				
JUB	SS				JUB
JUI	DE				
JUJ	AR				JUJ
JUL	PE				JUL
JUM	NP				
JUN	AU				
JUO	CO				
JUR	AU				
JUT	HN				
JUV	GL				
JUZ	CN				JUZ
JVA	MG				
JVI	US				
JVL	US				
JWA	BW				
JXN	US				
JYV	FI				
JZH	CN				
KAA	ZM				
KAB	ZW				
KAC	SY				
KAD	NG				
KAE	US				
KAF	PG				
KAG	KR				
KAI	GY				
KAJ	FI				
KAK	PG				
KAL	US				
KAM	YE				
KAN	NG				KAN
KAO	FI				KAO
KAP	ZR				
KAQ	PG				
KAR	GY				
KAS	NA				
KAT	NZ				
KAU	FI				
KAV	VE				
KAW	MM				
KAX	AU				
KAY	FJ				
KAZ	ID				
KBA	SL				
KBB	AU				
KBC	US				
KBD	AU				
KBE	US				
KBF	ID				
KBG	UG				
KBH	PK				
KBI	CM				
KBJ	AU				
KBK	US				
KBL	AF				KBL
KBM	PG				
KBN	ZR				
KBO	ZR				
KBQ	MW				
KBR	MY				KBR
KBS	SL				
KBT	MH				
KBU	ID				
KBV	TH				KBV
KBX	ID				
KBY	AU				
KBZ	NZ				
KCA	CN				
KCB	SR				
KCC	US				
KCE	AU				
KCH	MY				KCH
KCI	ID				
KCK	US				
KCL	US				
KCM	TR				KCM
KCN	US				
KCP	UA				
KCR	US				
KCS	AU				
KCU	UG				
KCZ	JP				KCZ
KDA	SN				
KDB	AU				
KDC	BJ				
KDD	PK				
KDE	PG				
KDG	BG				
KDH	AF				
KDI	ID				
KDJ	GA				
KDL	EE				
KDN	GA				
KDP	PG				
KDR	PG				
KDS	AU				
KDU	PK				
KDV	FJ				
KEA	ID				
KEB	US				
KEC	ZR				
KED	MR				
KEE	CG				
KEG	PG				
KEH	US				
KEI	ID				
KEJ	RU				
KEK	US				
KEL	DE				
KEM	FI				
KEN	SL				
KEO	CI				
KEP	NP				
KEQ	ID				
KER	IR				
KES	CA				
KET	MM				
KEU	US				
KEV	FI				
KEX	PG				
KEY	KE				
KFA	MR				
KFG	AU				
KFP	US				
KFS	TR				KFS
KGA	ZR				
KGB	PG				
KGC	AU				
KGD	RU				KGD
KGF	KZ				
KGG	SN				
KGH	PG				
KGI	AU				
KGJ	MW				
KGK	US				
KGL	RW				KGL
KGM	PG				
KGN	ZR				
KGO	UA				
KGR	AU				
KGS	GR				KGS
KGU	MY				
KGW	PG				
KGX	US				
KGY	AU				
KGZ	US				
KHA	IR				
KHC	UA				
KHE	UA				KHE
KHG	CN				KHG
KHH	TW				KHH
KHI	PK				KHI
KHJ	FI				
KHK	IR				
KHL	BD				
KHM	MM				
KHN	CN				KHN
KHO	ZA				
KHR	MN				
KHS	OM				
KHT	AF				
KHU	UA				
KHV	RU				KHV
KHW	BW				
KIA	PG				
KIB	US				
KIC	US				
KID	SE				
KIE	PG				
KIF	CA				
KIG	ZA				
KIH	IR				
KIJ	JP				KIJ
KIK	IQ				
KIL	ZR				
KIM	ZA				KIM
KIN	JM				KIN
KIO	MH				
KIQ	PG				
KIR	IE				
KIS	KE				
KIT	GR				
KIU	KE				
KIV	MD				KIV
KIW	ZM				
KIY	TZ				
KIZ	PG				
KJA	RU				KJA
KJK	BE				
KJP	JP				
KJU	PG				
KKA	US				
KKB	US				
KKC	TH				KKC
KKD	PG				
KKE	NZ				KKE
KKF	US				
KKG	GY				
KKH	US				
KKI	US				
KKJ	JP				KKJ
KKK	US				
KKL	US				
KKM	TH				
KKN	NO				KKN
KKO	NZ				
KKP	AU				
KKR	PF				
KKT	US				
KKU	US				
KKW	ZR				
KKX	JP				
KKY	IE				
KKZ	KH				
KLB	ZM				
KLC	SN				
KLD	RU				
KLE	CM				
KLF	RU				
KLG	US				
KLH	IN				
KLI	ZR				
KLJ	LT				
KLK	KE				
KLL	US				
KLN	US				
KLO	PH				KLO
KLP	US				
KLQ	ID				
KLR	SE				KLR
KLS	US				
KLT	DE				KLT
KLU	AT				KLU
KLV	CZ				
KLW	US				
KLX	GR				KLX
KLY	ZR				
KLZ	ZA				
KMA	PG				
KMB	PG				
KMD	GA				
KME	RW				
KMF	PG				
KMG	CN				KMG
KMH	ZA				
KMI	JP				KMI
KMJ	JP				KMJ
KMK	CG				
KML	AU				
KMM	ID				
KMN	ZR				
KMO	US				
KMP	NA				
KMQ	JP				KMQ
KMR	PG				
KMS	GH				
KMT	KH				
KMU	SO				
KMV	MM				
KMW	RU				
KMX	SA				
KMY	US				
KMZ	ZM				
KNA	CL				
KNB	US				
KNC	CN				KNC
KND	ZR				
KNE	PG				
KNF	GB				
KNG	ID				
KNH	TW				
KNI	AU				
KNJ	CG				
KNK	US				
KNL	PG				
KNM	ZR				
KNN	GN				
KNO	BE				
KNQ	NC				
KNR	IR				
KNS	AU				
KNT	US				
KNU	IN				KNU
KNW	US				
KNX	AU				
KNY	CA				
KNZ	ML				
KOA	US				KOA
KOB	CM				
KOC	NC				
KOD	ID				
KOE	ID				
KOF	ZA				
KOG	LA				
KOH	AU				
KOI	GB				
KOJ	JP				KOJ
KOK	FI				
KOL	CF				
KOM	PG				
KON	VN				
KOO	ZR				
KOP	TH				
KOR	PG				
KOS	KH				
KOT	US				
KOU	GA				
KOV	KZ				
KOW	CN				KOW
KOX	ID				
KOY	US				
KOZ	US				
KPA	PG				
KPB	US				
KPC	US				
KPD	US				
KPE	PG				
KPG	GY				
KPH	US				
KPI	MY				
KPK	US				
KPM	PG				
KPN	US				
KPO	KR				KPO
KPP	AU				
KPR	US				
KPS	AU				
KPT	US				
KPV	US				
KPY	US				
KQA	US				
KQB	AU				
KQL	PG				
KRA	AU				
KRB	AU				
KRC	ID				
KRD	AU				
KRE	BI				
KRF	SE				
KRG	GY				
KRI	PG				
KRJ	PG				
KRK	PL				KRK
KRL	CN				KRL
KRM	GY				
KRN	SE				KRN
KRO	RU				
KRP	DK				
KRQ	UA				
KRR	RU				KRR
KRS	NO				KRS
KRT	SD				KRT
KRU	PG				
KRV	KE				
KRW	TM				
KRX	PG				
KRY	CN				KRY
KRZ	ZR				
KSA	FM				KSA
KSB	PG				
KSC	SK				KSC
KSD	SE				KSD
KSE	UG				
KSF	DE				KWQ
KSG	PG				
KSH	IR				
KSI	GN				
KSJ	GR				
KSK	SE				
KSL	SD				
KSM	US				
KSN	KZ				
KSO	GR				
KSP	PG				
KSQ	UZ				
KSR	US				
KSS	ML				
KST	SD				
KSU	NO				KSU
KSV	AU				
KSW	IL				
KSX	PG				
KSY	TR				KSY
KSZ	RU				
KTA	AU				
KTB	US				
KTC	CI				
KTD	JP				
KTE	MY				
KTF	NZ				
KTG	ID				
KTH	US				
KTI	KH				
KTK	PG				
KTL	KE				
KTM	NP				KTM
KTN	US				KTN
KTO	GY				
KTQ	FI				
KTR	AU				
KTS	US				
KTT	FI				KTT
KTU	IN				
KTV	VE				
KTW	PL				KTW
KTX	ML				
KUA	MY				KUA
KUB	BN				
KUC	KI				
KUD	MY				
KUE	SB				
KUF	RU				KUF
KUG	AU				
KUH	JP				KUH
KUI	NZ				
KUJ	JP				
KUK	US				
KUL	MY				KUL
KUM	JP				
KUN	LT				KUN
KUO	FI				KUO
KUP	PG				
KUQ	PG				
KUR	AF				
KUS	GL				
KUT	GE				
KUU	IN				
KUV	KR				
KUW	US				
KUZ	KR				
KVA	GR				KVA
KVB	SE				
KVC	US				
KVD	AZ				
KVE	PG				
KVG	PG				
KVK	RU				
KVL	US				
KVU	FJ				
KVX	RU				KVX
KWA	MH				KWA
KWB	ID				
KWD	CF				
KWE	CN				KWE
KWF	US				
KWG	UA				
KWH	AF				
KWI	KW				KWI
KWJ	KR				KWJ
KWK	US				
KWL	CN				KWL
KWM	AU				
KWN	US				
KWO	PG				
KWP	US				
KWR	SB				
KWS	SB				
KWT	US				
KWU	NZ				
KWV	PG				
KWX	PG				
KWY	KE				
KWZ	ZR				
KXA	US				
KXE	ZA				
KXF	FJ				
KXK	RU				
KXR	PG				
KYA	TR				KYA
KYB	AU				
KYD	TW				
KYE	LB				
KYF	AU				
KYI	AU				
KYK	US				
KYL	US				
KYN	GB				
KYP	MM				
KYS	ML				
KYT	MM				
KYU	US				
KYX	PG				
KYZ	RU				
KZB	US				
KZC	KH				
KZD	KH				
KZF	PG				
KZH	US				
KZI	GR				
KZK	KH				
KZN	RU				KZN
KZR	TR				
KZS	GR				
LAA	US				
LAB	PG				
LAC	MY				
LAD	AO				LAD
LAE	PG				
LAF	US				
LAG	VE				
LAH	ID				
LAI	FR				
LAJ	BR				
LAK	CA				
LAL	US				
LAM	US				
LAN	US				LAN
LAO	PH				
LAP	MX				LAP
LAQ	LY				
LAR	US				LAR
LAS	US				LAS
LAT	CO				
LAU	KE				
LAV	WS				
LAW	US				
LAX	US				LAX
LAY	ZA				
LAZ	BR				
LBA	GB				
LBB	US				LBB
LBC	DE				
LBD	TJ				
LBE	US				
LBF	US				LBF
LBI	FR				
LBJ	ID				
LBK	KE				
LBL	US				LBL
LBM	MZ				
LBN	KE				
LBO	ZR				
LBQ	GA				
LBR	BR				
LBS	FJ				
LBT	US				
LBU	MY				LBU
LBV	GA				LBV
LBW	ID				
LBX	PH				
LBY	FR				
LCA	CY				LCA
LCB	BR				
LCC	IT				
LCD	ZA				
LCE	HN				
LCG	ES				
LCH	US				LCH
LCI	US				
LCJ	PL				LCJ
LCL	CU				
LCM	AR				
LCN	AU				
LCO	CG				
LCR	CO				
LCS	CR				
LCV	IT				
LDA	IN				
LDB	BR				LDB
LDC	AU				
LDE	FR				LDE
LDH	AU				
LDI	TZ				
LDJ	US				
LDK	SE				
LDM	US				
LDN	NP				
LDO	SR				
LDR	YE				
LDU	MY				
LDV	FR				
LDW	AU				
LDX	GF				
LDY	GB				
LDZ	ZA				
LEA	AU				
LEB	US				
LED	RU				LED
LEE	US				
LEF	LS				
LEG	MR				
LEH	FR				
LEI	ES				LEI
LEJ	DE				LEJ
LEK	GN				
LEL	AU				
LEM	US				
LEO	GA				
LEP	BR				
LEQ	GB				
LER	AU				
LES	LS				
LET	CO				LET
LEU	ES				
LEV	FJ				
LEW	US				
LEX	US				LEX
LEY	NL				
LEZ	HN				
LFN	US				
LFO	ET				
LFP	AU				
LFQ	CN				LFQ
LFR	VE				
LFT	US				LFT
LFW	TG				LFW
LGB	US				LGB
LGC	US				
LGD	US				
LGG	BE				LGG
LGH	AU				
LGI	BS				
LGK	MY				LGK
LGL	MY				
LGM	PG				
LGN	PG				
LGO	DE				
LGP	PH				
LGQ	EC				
LGR	CL				
LGS	AR				
LGT	CO				
LGU	US				
LGX	SO				
LGY	VE				
LGZ	CO				
LHA	DE				
LHB	US				
LHE	PK				LHE
LHG	AU				
LHI	ID				
LHK	CN				
LHN	TW				
LHP	PG				
LHS	AR				
LHV	US				
LHW	CN				LHW
LIA	CN				
LIB	AU				
LIC	US				
LID	NL				
LIE	ZR				
LIF	NC				
LIG	FR				
LIH	US				LIH
LII	ID				
LIJ	US				
LIK	MH				
LIL	FR				
LIM	PE				LIM
LIO	CR				
LIP	BR				
LIQ	ZR				
LIR	CR				LIR
LIS	PT				LIS
LIT	US				LIT
LIV	US				
LIW	MM				
LIX	MW				
LIY	US				
LIZ	US				
LJA	ZR				
LJG	CN				LJG
LJN	US				
LJU	SI				LJU
LKA	ID				
LKB	FJ				
LKC	CG				
LKD	AU				
LKK	US				
LKL	NO				
LKN	NO				
LKO	IN				LKO
LKP	US				
LKR	SO				
LKS	US				
LKT	CI				
LKU	KE				
LKV	US				
LKY	TZ				
LKZ	GB				
LLA	SE				LLA
LLE	ZA				
LLG	AU				
LLH	HN				
LLI	ET				LLI
LLL	AU				
LLM	MY				
LLN	ID				
LLP	AU				
LLS	AR				
LLW	MW				LLW
LLX	US				
LLY	US				
LMA	US				
LMB	MW				
LMC	CO				
LMD	AR				
LME	FR				
LMG	PG				
LMH	HN				
LMI	PG				
LML	MH				
LMM	MX				
LMN	MY				
LMO	GB				
LMP	IT				LMP
LMQ	LY				
LMR	ZA				
LMS	US				
LMT	US				
LMX	CO				
LMY	PG				
LMZ	MZ				
LNB	VU				
LNC	PG				
LND	US				
LNE	VU				
LNF	PG				
LNG	PG				
LNH	AU				
LNI	US				
LNK	US				LNK
LNM	PG				
LNN	US				
LNO	AU				
LNP	US				
LNQ	PG				
LNR	US				
LNS	US				
LNV	PG				
LNX	RU				
LNY	US				LNY
LNZ	AT				LNZ, LZS
LOA	AU				
LOB	CL				
LOC	AU				
LOD	VU				
LOE	TH				
LOF	MH				
LOG	US				
LOH	EC				
LOK	KE				
LOL	US				
LOM	MX				
LON	GB				LCY, LHR, STN, LGW, LTN, SEN
LOO	DZ				
LOP	ID				
LOQ	BW				
LOS	NG				LOS
LOT	US				
LOV	MX				
LOW	US				
LOY	KE				
LOZ	US				
LPA	ES				LPA
LPB	BO				LPB
LPC	US				
LPD	CO				
LPE	CO				
LPG	AR				
LPH	GB				
LPI	SE				LPI
LPJ	VE				
LPK	RU				
LPL	GB				
LPM	VU				
LPN	PG				
LPO	US				
LPP	FI				
LPQ	LA				LPQ
LPS	US				
LPT	TH				LPT
LPU	ID				
LPW	US				
LPX	LV				
LPY	FR				
LQK	US				
LQM	CO				
LQN	AF				
LRA	GR				
LRB	LS				
LRC	DE				
LRD	US				LRD
LRE	AU				
LRF	US				
LRG	PK				
LRH	FR				
LRI	CO				
LRJ	US				
LRK	US				
LRL	TG				
LRM	DO				LRM
LRO	US				
LRQ	CA				
LRS	GR				
LRT	FR				
LRU	US				
LRV	VE				
LSA	PG				
LSB	US				
LSC	CL				LSC
LSE	US				
LSH	MM				
LSJ	PG				
LSK	US				
LSL	CR				
LSM	MY				
LSN	US				
LSO	FR				
LSP	VE				LSP
LSQ	CL				
LSR	US				
LSS	GP				
LST	AU				LST
LSU	MY				
LSW	ID				
LSX	ID				
LSY	AU				
LSZ	HR				
LTA	ZA				
LTB	AU				
LTC	TD				
LTD	LY				
LTF	PG				
LTG	NP				
LTH	US				
LTI	MN				
LTK	SY				
LTL	GA				
LTM	GY				
LTO	MX				
LTP	AU				
LTQ	FR				
LTR	IE				
LTS	US				
LTT	FR				
LTV	AU				
LTW	US				
LUA	NP				
LUB	GY				
LUC	FJ				
LUD	NA				
LUE	SK				
LUG	CH				LUG
LUH	IN				
LUI	HN				
LUJ	ZA				
LUL	US				
LUM	CN				
LUN	ZM				LUN
LUO	AO				
LUP	US				
LUQ	AR				
LUR	US				
LUS	ZR				
LUT	AU				
LUU	AU				
LUV	ID				
LUW	ID				
LUX	LU				LUX
LUY	TZ				
LUZ	PL				LUZ
LVA	FR				
LVB	BR				
LVD	US				
LVI	ZM				LVI
LVK	US				
LVL	US				
LVM	US				
LVO	AU				
LVP	IR				
LVS	US				
LWA	PH				
LWB	US				LWB
LWC	US				
LWE	ID				
LWH	AU				
LWI	PG				
LWL	US				
LWM	US				
LWN	AM				
LWO	UA				LWO
LWR	NL				
LWS	US				LWS
LWT	US				
LWV	US				
LWY	MY				
LXA	CN				LXA
LXG	LA				
LXI	CN				
LXN	US				
LXR	EG				LXR
LXS	GR				KUN
LXU	ZM				
LXV	US				
LYA	CN				
LYB	KY				
LYC	SE				
LYE	GB				
LYG	CN				
LYH	US				LYH
LYI	CN				LYI
LYK	ID				
LYO	US				
LYP	PK				
LYR	NO				LYR
LYS	FR				LYS
LYT	AU				
LYU	US				
LYX	GB				
LZA	ZR				
LZC	MX				
LZH	CN				LZH
LZI	ZR				
LZO	CN				
LZR	AU				
LZY	CN				LZY
MAA	IN				MAA
MAB	BR				
MAD	ES				MAD
MAE	US				
MAF	US				MAF
MAG	PG				
MAH	ES				MAH
MAI	MW				
MAJ	MH				MAJ
MAK	SD				
MAL	ID				
MAM	MX				
MAN	GB				MAN
MAO	BR				MAO
MAP	PG				
MAQ	TH				
MAR	VE				MAR
MAS	PG				
MAT	ZR				
MAU	PF				
MAV	MH				
MAW	US				
MAX	SN				
MAY	BS				
MAZ	PR				
MBA	KE				MBA
MBB	AU				
MBC	GA				
MBD	ZA				
MBE	JP				MBE
MBF	AU				
MBG	US				
MBH	AU				
MBI	TZ				
MBJ	JM				MBJ
MBK	BR				
MBL	US				
MBM	ZA				
MBN	AU				
MBO	PH				
MBP	PE				
MBQ	UG				
MBR	MR				
MBS	US				MBS
MBT	PH				
MBU	SB				
MBV	PG				
MBW	AU				
MBX	SI				
MBY	US				
MBZ	BR				
MCA	GN				
MCB	US				
MCD	US				
MCE	US				
MCG	US				
MCH	EC				
MCJ	CO				
MCK	US				MCK
MCL	US				
MCM	MC				
MCN	US				
MCP	BR				
MCQ	HU				
MCR	GT				
MCS	AR				
MCT	OM				MCT
MCU	FR				
MCV	AU				
MCW	US				
MCX	RU				
MCY	AU				
MCZ	BR				MCZ
MDB	BZ				
MDC	ID				MDC
MDE	CO				MDE
MDF	US				
MDG	CN				
MDH	US				
MDI	NG				
MDJ	US				
MDK	ZR				
MDL	MM				MDL
MDM	PG				
MDN	US				
MDO	US				
MDP	ID				
MDQ	AR				
MDR	US				
MDS	TC				
MDU	PG				
MDV	GA				
MDX	AR				
MDY	UM				
MDZ	AR				MDZ
MEA	BR				
MEC	EC				
MED	SA				MED
MEE	NC				
MEF	TD				
MEG	AO				
MEH	NO				
MEI	US				
MEJ	US				
MEK	MA				
MEL	AU				MEL
MEM	US				MEM
MEN	FR				
MEO	US				
MEP	MY				
MEQ	ID				
MES	ID				MES, KNO
MET	AU				
MEU	BR				
MEV	US				
MEW	ZR				
MEX	MX				MEX
MEY	NP				
MEZ	ZA				
MFA	TZ				
MFB	CO				
MFC	LS				
MFD	US				
MFE	US				MFE
MFF	GA				
MFG	PK				
MFI	US				
MFJ	FJ				
MFL	AU				
MFM	MO				MFM
MFN	NZ				
MFO	EG				
MFP	AU				
MFQ	NE				
MFR	US				MFR
MFS	CO				
MFU	ZM				
MFV	US				
MFX	FR				
MFY	YE				
MGA	NI				MGA
MGB	AU				
MGC	US				
MGD	BO				
MGF	BR				MGF
MGG	PG				
MGH	ZA				
MGI	US				
MGJ	US				
MGK	MM				
MGL	DE				
MGM	US				MGM
MGN	CO				
MGO	GA				
MGP	PG				
MGQ	SO				MGQ
MGR	US				
MGS	CK				
MGT	AU				
MGU	MM				
MGV	AU				
MGW	US				MGW
MGX	GA				
MGZ	MM				
MHA	GY				
MHC	AU				
MHD	IR				MHD
MHE	US				
MHF	CO				
MHG	DE				MHJ
MHH	BS				
MHI	DJ				
MHJ	ET				
MHK	US				
MHL	US				
MHM	US				
MHN	US				
MHO	AU				
MHQ	FI				
MHS	US				
MHT	US				MHT
MHU	AU				
MHV	US				
MHX	CK				
MHY	PG				
MHZ	GB				
MIA	US				MIA
MID	MX				MID
MIE	US				
MIF	US				
MIG	CN				MIG
MIH	AU				
MII	BR				
MIJ	MH				
MIK	FI				
MIL	IT				BGY, LIN, MXP
MIM	AU				
MIN	AU				
MIP	IL				
MIR	TN				MIR
MIS	PG				
MIT	US				
MIU	NG				
MIV	US				
MIW	US				
MIX	CO				
MIY	AU				
MIZ	AU				
MJA	MG				
MJB	MH				
MJC	CI				
MJD	PK				
MJE	MH				
MJF	NO				
MJG	CU				
MJH	SA				
MJI	LY				
MJJ	PG				
MJK	AU				
MJL	GA				
MJM	CG				MJM
MJN	MG				
MJP	AU				
MJQ	US				
MJR	AR				
MJS	MZ				
MJT	GR				MJT
MJU	ID				
MJV	ES				
MJY	ID				
MJZ	RU				
MKA	CZ				
MKB	GA				
MKC	US				MCI, MKC
MKD	ET				
MKE	US				MKE
MKG	US				MKG
MKH	LS				
MKI	CF				
MKJ	CG				
MKK	US				MKK
MKL	US				
MKM	MY				
MKN	PG				
MKO	US				
MKP	PF				
MKQ	ID				
MKR	AU				
MKS	ET				
MKT	US				
MKU	GA				
MKV	AU				
MKW	ID				
MKX	YE				
MKY	AU				
MKZ	MY				
MLA	MT				MLA
MLB	US				MLB
MLC	US				
MLD	US				
MLE	MV				MLE
MLF	US				
MLG	ID				
MLH	FR				MLH
MLI	US				MLI
MLJ	US				
MLK	US				
MLL	US				
MLM	MX				MLM
MLN	ES				
MLO	GR				
MLP	PH				
MLQ	PG				
MLR	AU				
MLS	US				
MLT	US				
MLU	US				MLU
MLV	AU				
MLW	LR				ROB
MLX	TR				MLX
MLY	US				
MLZ	UY				
MMA	SE				MMX
MMB	JP				MMB
MMC	MX				
MMD	JP				
MME	GB				
MMF	CM				
MMG	AU				
MMH	US				MMH
MMI	US				
MMJ	JP				
MMK	RU				MMK
MML	US				
MMM	AU				
MMN	US				
MMO	CV				
MMP	CO				
MMQ	ZM				
MMS	US				
MMU	US				
MMV	PG				
MMW	MZ				
MMY	JP				MMY
MMZ	AF				
MNA	ID				
MNB	ZR				
MNC	MZ				
MND	CO				
MNE	AU				
MNF	FJ				
MNG	AU				
MNH	LK				
MNI	MS				
MNJ	MG				
MNK	KI				
MNL	PH				MNL
MNM	US				
MNN	US				
MNO	ZR				
MNP	PG				
MNQ	AU				
MNR	ZM				
MNS	ZM				
MNT	US				
MNU	MM				
MNV	AU				
MNW	AU				
MNX	BR				
MNY	SB				
MNZ	US				
MOA	CU				
MOB	US				BFM, MOB
MOC	BR				
MOD	US				MOD
MOE	MM				
MOF	ID				
MOG	MM				
MOH	IN				
MOI	CK				
MOJ	SR				
MOK	CI				
MOL	NO				MOL
MOM	MR				
MON	NZ				
MOO	AU				
MOP	US				
MOQ	MG				
MOR	US				
MOS	US				
MOT	US				MOT
MOU	US				
MOV	AU				
MOW	RU				DME, SVO, VKO
MOX	US				
MOY	CO				
MOZ	PF				
MPA	NA				
MPC	ID				
MPD	PK				
MPE	US				
MPF	PG				
MPG	PG				
MPH	PH				
MPI	PA				
MPJ	US				
MPK	KR				
MPL	FR				MPL
MPM	MZ				MPM
MPN	FK				
MPO	US				
MPP	PA				
MPQ	JO				
MPR	US				
MPS	US				
MPT	ID				
MPU	PG				
MPV	US				
MPW	UA				
MPX	PG				
MPY	GF				
MPZ	US				
MQA	AU				
MQB	US				
MQC	PM				
MQD	AR				
MQE	AU				
MQF	RU				
MQH	BR				
MQI	US				
MQL	AU				
MQM	TR				MQM
MQN	NO				
MQQ	TD				
MQR	CO				
MQS	VC				
MQT	US				
MQU	CO				
MQW	US				
MQX	ET				MQX
MQY	US				
MRA	LY				
MRB	US				
MRC	US				
MRD	VE				MRD
MRE	KE				
MRF	US				
MRG	AU				
MRH	PG				
MRJ	HN				
MRK	US				
MRL	AU				
MRM	PG				
MRN	US				
MRO	NZ				
MRP	AU				
MRQ	PH				
MRR	EC				
MRS	FR				MRS
MRT	AU				
MRU	MU				MRU
MRV	RU				MRV
MRW	DK				
MRX	IR				
MRY	US				MRY
MRZ	AU				
MSA	CA				
MSC	US				
MSD	US				
MSE	GB				
MSF	AU				
MSG	LS				
MSH	OM				
MSI	ID				
MSJ	JP				
MSK	BS				
MSL	US				
MSM	ZR				
MSN	US				MSN
MSO	US				MSO
MSP	US				MSP
MSQ	BY				MSQ
MSR	TR				
MSS	US				
MST	NL				
MSU	LS				MSU
MSV	US				
MSW	ER				
MSX	CG				
MSY	US				MSY
MSZ	AO				
MTA	NZ				
MTB	CO				
MTD	AU				
MTE	BR				
MTF	ET				
MTG	BR				
MTH	US				
MTI	CV				
MTJ	US				MTJ
MTK	KI				
MTL	AU				
MTM	US				
MTO	US				
MTP	US				
MTQ	AU				
MTR	CO				MTR
MTS	SZ				MTS
MTT	MX				
MTU	MZ				
MTV	VU				
MTW	US				
MTY	MX				MTY
MTZ	IL				
MUA	SB				
MUB	BW				MUB
MUC	DE				MUC
MUD	MZ				
MUE	US				
MUF	ID				
MUG	MX				
MUH	EG				
MUI	US				
MUJ	ET				
MUK	CK				
MUM	KE				
MUN	VE				MUN
MUO	US				
MUP	AU				
MUQ	AU				
MUR	MY				
MUS	JP				
MUT	US				
MUU	US				
MUW	DZ				
MUX	PK				
MUZ	TZ				
MVA	IS				
MVB	GA				
MVC	US				
MVD	UY				MVD
MVE	US				
MVF	BR				
MVG	GA				
MVH	AU				
MVI	PG				
MVJ	JM				
MVK	AU				
MVL	US				
MVM	US				
MVN	US				
MVO	TD				
MVP	CO				
MVQ	BY				
MVR	CM				
MVS	BR				
MVT	PF				
MVU	AU				
MVV	FR				
MVW	US				
MVX	GA				
MVY	US				
MVZ	ZW				
MWA	US				
MWB	AU				
MWD	PK				
MWE	SD				
MWF	VU				
MWG	PG				
MWH	US				MWH
MWI	PG				
MWJ	GY				
MWK	ID				
MWL	US				
MWM	US				
MWN	TZ				
MWO	US				
MWQ	MM				
MWR	ZA				
MWS	US				
MWT	AU				
MWU	PG				
MWX	KR				MWX
MWY	AU				
MWZ	TZ				
MXA	US				
MXB	ID				
MXC	US				
MXD	AU				
MXE	US				
MXG	US				
MXH	PG				
MXI	PH				
MXJ	NG				
MXK	PG				
MXL	MX				
MXM	MG				
MXN	FR				
MXO	US				
MXQ	AU				
MXR	UA				
MXS	WS				
MXT	MG				
MXU	AU				
MXV	MN				
MXW	MN				
MXX	SE				
MXY	US				
MXZ	CN				
MYA	AU				
MYB	GA				
MYC	VE				
MYD	KE				
MYE	JP				MYE
MYG	BS				
MYH	US				
MYI	AU				
MYJ	JP				MYJ
MYK	US				
MYL	US				
MYM	GY				
MYN	YE				
MYO	AU				
MYP	TM				
MYQ	IN				
MYR	US				MYR
MYS	ET				
MYT	MM				
MYU	US				
MYV	US				
MYW	TZ				
MYX	PG				
MYY	MY				MYY
MYZ	MW				
MZA	IN				
MZB	MZ				
MZC	GA				
MZD	EC				
MZE	BZ				
MZF	ZA				
MZG	TW				
MZH	TR				MZH
MZI	ML				
MZJ	US				
MZK	KI				
MZL	CO				MZL
MZN	PG				
MZO	CU				
MZP	NZ				
MZQ	ZA				
MZR	AF				MZR
MZS	MY				
MZT	MX				MZT
MZU	IN				
MZV	MY				
MZX	ET				
MZY	ZA				
MZZ	US				
NAA	AU				
NAC	AU				
NAD	CO				
NAE	BJ				
NAF	ID				
NAG	IN				NAG
NAH	ID				
NAI	GY				
NAK	TH				
NAL	RU				
NAM	ID				
NAN	FJ				NAN
NAO	CN				
NAP	IT				NAP
NAQ	GL				
NAR	CO				
NAS	BS				NAS
NAT	BR				NAT
NAU	PF				
NAV	TR				NAV
NAW	TH				
NAX	US				
NBA	PG				
NBB	CO				
NBC	RU				NBC
NBE	TN				NBE
NBH	AU				
NBL	PA				
NBO	KE				NBO
NBR	AU				
NBU	US				
NBV	BR				
NBX	ID				
NCA	TC				
NCE	FR				NCE
NCG	MX				
NCH	TZ				
NCI	CO				
NCL	GB				NCL
NCN	US				
NCO	US				
NCP	PH				
NCR	NI				
NCS	ZA				
NCT	CR				
NCU	UZ				
NCY	FR				
NDA	ID				
NDB	MR				
NDC	IN				
NDD	AO				
NDE	KE				
NDG	CN				NDG
NDI	PG				
NDJ	TD				NDJ
NDK	MH				
NDL	CF				
NDM	ET				
NDN	PG				
NDR	MA				NDR
NDS	AU				
NDU	NA				
NDV	US				
NDY	GB				
NDZ	DE				
NEA	US				
NEC	AR				
NEF	RU				
NEG	JM				
NEJ	ET				
NEK	ET				
NEL	US				
NEN	US				
NER	RU				
NEU	LA				
NEV	KN				
NFG	RU				
NFL	US				
NFO	TO				
NGA	AU				
NGB	CN				NGB
NGD	VG				
NGE	CM				
NGI	FJ				
NGL	ZA				
NGN	PA				
NGO	JP				NGO
NGR	PG				
NGS	JP				NGS
NGV	AO				
NGX	NP				
NGZ	US				
NHA	VN				
NHD	AE				
NHF	SD				
NHK	US				
NHS	PK				
NHT	GB				
NHV	PF				
NHX	US				
NIA	LR				
NIB	US				
NIC	CY				
NIE	US				
NIF	AU				
NIG	KI				
NIK	SN				
NIM	NE				NIM
NIN	US				
NIO	ZR				
NIR	US				
NIT	FR				
NIX	ML				
NJA	JP				
NJC	RU				
NKA	GA				
NKB	AU				
NKC	MR				NKC
NKD	ID				
NKG	CN				NKG
NKI	US				
NKL	ZR				
NKN	PG				
NKS	CM				
NKU	LS				
NKV	US				
NKY	CG				
NLA	ZM				NLA
NLC	US				
NLD	MX				
NLE	US				
NLF	AU				
NLG	US				
NLK	NF				NLK
NLL	AU				
NLP	ZA				NLP, MQP
NLS	AU				
NLV	UA				
NMA	UZ				
NMB	IN				
NMC	BS				
NME	US				
NMG	PA				
NMN	PG				
NMP	AU				
NMR	AU				
NMS	MM				
NMT	MM				
NMU	MH				
NNA	MA				
NNB	SB				
NND	MZ				
NNG	CN				NNG
NNI	NA				
NNK	US				
NNL	US				
NNM	RU				NNM
NNT	TH				
NNU	BR				
NNX	ID				
NNY	CN				
NOA	AU				
NOB	CR				
NOC	IE				NOC
NOD	DE				
NOE	DE				
NOG	MX				
NOI	RU				
NOJ	RU				
NOK	BR				
NOL	US				
NOM	PG				
NON	KI				
NOO	PG				
NOP	PH				
NOR	IS				
NOS	MG				NOS
NOT	US				
NOU	NC				NOU
NOV	AO				
NOZ	RU				
NPE	NZ				NPE
NPG	PG				
NPH	US				
NPL	NZ				
NPO	ID				
NPP	AU				
NPT	US				
NPU	CO				
NQI	US				
NQL	BR				
NQN	AR				NQN
NQT	GB				
NQU	CO				
NQY	GB				NQY
NRA	AU				
NRB	US				
NRC	US				
NRD	DE				
NRE	ID				
NRG	AU				
NRI	US				
NRK	SE				NRK
NRL	GB				
NRM	ML				
NRQ	AO				
NRS	US				
NRY	AU				
NSA	AU				
NSE	US				
NSH	IR				
NSK	RU				
NSM	AU				
NSN	NZ				NSN
NSO	AU				
NSP	PH				
NST	TH				NST
NSV	AU				
NSX	VG				
NSY	IT				
NTA	FJ				
NTB	NO				
NTC	MZ				
NTD	US				
NTE	FR				NTE
NTG	CN				NTG
NTI	ID				
NTJ	US				
NTL	AU				
NTM	BR				
NTN	AU				
NTO	CV				
NTQ	JP				NTQ
NTT	TO				
NTU	US				
NTX	ID				
NTY	ZA				
NUB	AU				
NUC	US				
NUD	SD				
NUE	DE				NUE, ZAQ
NUG	PG				
NUH	CO				
NUI	US				
NUK	PF				
NUL	US				
NUP	US				
NUQ	US				
NUR	AU				
NUS	VU				
NUT	PG				
NUU	KE				
NUW	US				
NUX	RU				
NVA	CO				NVA
NVD	US				
NVG	NI				
NVK	NO				
NVP	BR				
NVR	RU				
NVS	FR				
NVT	BR				NVT
NVY	IN				
NWA	KM				
NWH	US				
NWI	GB				
NWP	CA				
NWT	PG				
NXX	US				
NYC	US				EWR, JFK, LGA
NYE	KE				
NYI	GH				
NYK	KE				
NYM	RU				
NYN	AU				
NYO	SE				
NYU	MM				
NZE	GN				
NZO	KE				
NZW	US				
OAG	AU				
OAJ	US				OAJ
OAK	US				OAK
OAM	NZ				
OAN	HN				
OAX	MX				OAX
OBA	AU				
OBC	DJ				
OBD	ID				
OBE	US				
OBF	DE				
OBI	BR				
OBK	US				
OBM	PG				
OBN	GB				
OBO	JP				OBO
OBS	FR				
OBU	US				
OBX	PG				
OBY	GL				
OCA	US				
OCC	EC				
OCE	US				
OCF	US				
OCH	US				
OCI	US				
OCJ	JM				
OCN	US				
OCV	CO				
OCW	US				
ODA	CF				
ODB	ES				
ODD	AU				
ODE	DK				
ODH	GB				
ODJ	CF				
ODL	AU				
ODM	US				
ODN	MY				
ODR	AU				
ODS	UA				ODS
ODW	US				
ODY	LA				
OEA	US				
OEC	ID				
OEL	RU				
OEM	SR				
OEO	US				
OER	SE				OER
OES	AR				
OFI	CI				
OFJ	IS				
OFK	US				
OFU	AS				
OGA	US				
OGB	US				
OGD	US				
OGE	PG				
OGG	US				OGG
OGN	JP				
OGO	CI				
OGR	TD				
OGS	US				
OGU	TR				OGU
OGX	DZ				
OGZ	RU				OGZ
OHA	NZ				
OHD	MK				
OHI	NA				
OHO	RU				
OHR	DE				
OHT	PK				
OIC	US				
OIM	JP				OIM
OIR	JP				
OIT	JP				OIT
OKA	JP				OKA
OKB	AU				
OKC	US				OKC
OKE	JP				
OKF	NA				
OKG	CG				
OKH	GB				
OKI	JP				
OKJ	JP				OKJ
OKK	US				
OKL	ID				
OKM	US				
OKN	GA				
OKP	PG				
OKQ	ID				
OKR	AU				
OKS	US				
OKT	RU				
OKU	NA				
OKY	AU				
OLA	NO				
OLB	IT				OLB
OLD	US				
OLE	US				
OLF	US				
OLH	US				
OLI	IS				
OLJ	VU				
OLM	US				
OLN	AR				
OLO	CZ				
OLP	AU				
OLQ	PG				
OLS	US				
OLU	US				
OLV	US				
OLY	US				
OMA	US				OMA
OMB	GA				
OMC	PH				
OMD	NA				
OME	US				OME
OMF	JO				
OMG	NA				
OMH	IR				
OMJ	JP				
OMK	US				
OML	PG				
OMM	OM				
OMN	IN				
OMO	BA				OMO
OMR	RO				
OMS	RU				
OMY	KH				
ONA	US				
ONB	PG				
OND	NA				
ONE	SB				
ONG	AU				
ONH	US				
ONI	ID				
ONJ	JP				ONJ
ONL	US				
ONN	US				
ONO	US				
ONP	US				
ONR	AU				
ONS	AU				
ONT	US				ONT
ONU	FJ				
ONX	PA				
ONY	US				
OOA	US				
OOK	US				
OOL	AU				OOL
OOM	AU				
OOR	AU				
OOT	KI				
OPA	IS				
OPB	PG				
OPI	AU				
OPL	US				
OPO	PT				OPO
OPS	BR				
OPU	PG				
OPW	NA				
ORA	AR				
ORB	SE				ORB
ORC	CO				
ORE	FR				
ORF	US				ORF
ORH	US				
ORI	US				
ORJ	GY				
ORK	IE				ORK
ORL	US				MCO
ORM	GB				
ORN	DZ				
ORO	HN				
ORP	BW				
ORQ	US				
ORR	AU				
ORS	AU				
ORT	US				
ORU	BO				
ORV	US				
ORW	PK				
ORX	BR				
ORZ	BZ				
OSA	JP				ITM, KIX, UKB
OSB	US				
OSC	US				
OSD	SE				OSD
OSE	PG				
OSG	PG				
OSH	US				
OSI	HR				OSI
OSK	SE				
OSL	NO				OSL
OSM	IQ				
OSN	KR				
OSP	PL				
OSR	CZ				
OSS	KG				
OST	BE				
OSW	RU				
OSX	US				
OSY	NO				
OSZ	PL				
OTA	ET				
OTC	TD				
OTD	PA				
OTG	US				
OTH	US				OTH
OTI	ID				
OTL	MR				
OTM	US				
OTN	US				
OTO	US				
OTR	CR				
OTS	US				
OTU	CO				
OTY	PG				
OTZ	US				OTZ
OUA	BF				OUA
OUD	MA				
OUE	CG				
OUG	BF				
OUH	ZA				
OUI	LA				
OUK	GB				
OUL	FI				OUL
OUM	TD				
OUN	US				
OUR	CM				
OUS	BR				
OUT	TD				
OUU	GA				
OUZ	MR				
OVA	MG				
OVB	RU				
OVD	ES				
OVE	US				
OVL	CL				
OWA	US				
OWB	US				
OWD	US				
OWE	GA				
OWK	US				
OXB	GW				OXB
OXC	US				
OXD	US				
OXF	GB				
OXO	AU				
OXR	US				OXR
OXY	AU				
OYA	AR				
OYE	GA				
OYG	UG				
OYK	BR				
OYL	KE				
OYN	AU				
OYO	AR				
OYP	GF				
OYS	US				
OZA	US				
OZC	PH				
OZH	UA				OZH
OZP	ES				
OZZ	MA				
PAA	MM				
PAB	IN				
PAD	DE				PAD
PAE	US				
PAF	UG				
PAG	PH				
PAH	US				PAH
PAI	KH				
PAJ	PK				
PAK	US				
PAL	CO				
PAN	TH				
PAO	US				
PAP	HT				PAP
PAQ	US				
PAR	FR				CDG, ORY
PAS	GR				PAS
PAT	IN				PAT
PAU	MM				
PAV	BR				
PAW	PG				
PAX	HT				
PAY	MY				
PAZ	MX				
PBB	BR				
PBC	MX				PBC
PBD	IN				
PBE	CO				
PBF	US				
PBG	US				PBG
PBH	BT				
PBI	US				PBI
PBJ	VU				
PBK	US				
PBL	VE				
PBM	SR				
PBN	AO				
PBO	AU				
PBQ	BR				
PBR	GT				
PBS	TH				
PBU	MM				
PBW	ID				
PBZ	ZA				
PCA	US				
PCB	ID				
PCC	CO				
PCD	US				
PCE	US				
PCG	GT				
PCH	HN				
PCK	US				
PCL	PE				
PCM	MX				
PCN	NZ				
PCO	MX				
PCP	ST				
PCR	CO				
PCS	BR				
PCT	US				
PCU	US				
PCV	MX				
PDA	CO				
PDB	US				
PDC	NC				
PDE	AU				
PDF	BR				
PDG	ID				
PDI	PG				
PDL	PT				PDL
PDN	AU				
PDO	ID				
PDP	UY				PDP
PDR	BR				
PDS	MX				
PDT	US				
PDU	UY				
PDV	BG				
PDX	US				PDX
PDZ	VE				
PEA	AU				
PEB	MZ				
PEC	US				
PEE	RU				PEE
PEG	IT				PEG
PEH	AR				
PEI	CO				PEI
PEL	LS				
PEM	PE				PEM
PEN	MY				PEN
PEP	AU				
PEQ	US				
PER	AU				PER
PES	RU				
PET	BR				
PEU	HN				
PEV	HU				
PEW	PK				PEW
PEX	RU				
PEY	AU				
PEZ	RU				
PFA	US				
PFB	BR				
PFC	US				
PFD	US				
PFJ	IS				
PFN	US				PFN
PFO	CY				PFO
PFR	ZR				
PGA	US				PGA
PGB	PG				
PGC	US				
PGD	US				
PGE	PG				
PGF	FR				
PGG	BR				
PGH	IN				
PGI	AO				
PGK	ID				
PGL	US				
PGM	US				
PGN	PG				
PGO	US				
PGP	ST				
PGR	US				
PGS	US				
PGV	US				PGV
PGX	FR				
PGZ	BR				
PHA	VN				
PHB	BR				
PHC	NG				PHC
PHD	US				
PHE	AU				
PHF	US				PHF
PHH	VN				
PHI	BR				
PHJ	AU				
PHK	US				
PHL	US				PHL, ZFV
PHM	DE				
PHN	US				
PHO	US				
PHP	US				
PHR	FJ				
PHS	TH				TDX
PHT	US				
PHU	VN				
PHW	ZA				PHW
PHX	US				PHX
PHZ	TH				
PIA	US				PIA
PIC	TC				
PIE	US				
PIG	BR				
PIH	US				
PIL	PY				
PIM	US				
PIN	BR				
PIO	PE				
PIP	US				
PIQ	GY				
PIR	US				PIR
PIS	FR				
PIT	US				PIT
PIU	PE				
PIV	BR				
PIW	CA				
PIX	PT				
PIZ	US				
PJB	US				
PJC	PY				
PJG	PK				
PJM	CR				
PJS	US				
PJZ	MX				
PKA	US				
PKB	US				PKB
PKC	RU				
PKD	US				
PKE	AU				
PKF	US				
PKG	MY				
PKH	GR				
PKK	MM				
PKL	NZ				
PKM	GY				
PKN	ID				
PKO	BJ				
PKP	PF				
PKR	NP				
PKS	LA				
PKT	AU				
PKU	ID				PKU
PKV	RU				
PKW	BW				
PKY	ID				
PKZ	LA				
PLA	CO				
PLB	US				
PLC	CO				
PLD	CR				
PLE	PG				
PLF	TD				
PLG	FR				
PLH	GB				
PLI	VC				
PLJ	BZ				
PLK	US				
PLL	BR				
PLM	ID				PLM
PLN	US				
PLO	AU				
PLP	PA				
PLQ	LT				PLQ
PLR	US				
PLS	TC				PLS
PLT	CO				
PLV	UA				
PLW	ID				
PLX	KZ				
PLY	US				
PLZ	ZA				PLZ
PMA	TZ				
PMB	US				
PMC	CL				PMC
PMD	US				
PME	GB				
PMF	IT				
PMG	BR				
PMH	US				
PMI	ES				PMI
PMK	AU				
PML	US				
PMM	TH				
PMN	PG				
PMO	IT				PMO
PMP	PG				
PMQ	AR				
PMR	NZ				PMR
PMS	SY				
PMT	GY				
PMU	US				
PMV	VE				PMV
PMW	BR				
PMX	US				
PMY	AR				
PMZ	CR				
PNA	ES				PNA
PNB	BR				
PNC	US				
PND	BZ				
PNF	US				
PNG	BR				
PNH	KH				PNH
PNI	FM				PNI
PNK	ID				
PNL	IT				PNL
PNN	US				
PNO	MX				
PNP	PG				
PNQ	IN				PNQ
PNR	CG				PNR
PNS	US				PNS
PNT	CL				
PNU	US				
PNV	LT				
PNX	US				
PNY	IN				
PNZ	BR				PNZ
POA	BR				POA
POC	US				
POD	SN				
POE	US				
POF	US				
POG	GA				
POH	US				
POI	BO				
POL	MZ				POL
POM	PG				
PON	GT				
POO	BR				
POP	DO				POP
POQ	US				
POR	FI				
POS	TT				POS
POT	JM				
POU	US				
POV	SK				
POW	SI				
POX	FR				
POY	US				
POZ	PL				POZ
PPA	US				
PPB	BR				
PPC	US				
PPE	MX				
PPF	US				
PPG	AS				
PPH	VE				
PPI	AU				
PPJ	ID				
PPK	KZ				
PPL	NP				
PPM	US				
PPN	CO				
PPO	BS				
PPP	AU				
PPQ	NZ				
PPR	ID				
PPS	PH				
PPT	PF				PPT
PPU	MM				
PPV	US				
PPW	GB				
PPY	BR				
PPZ	VE				
PQC	VN				
PQI	US				
PQM	MX				
PQQ	AU				
PQS	US				
PRA	AR				
PRB	US				
PRC	US				PRC
PRD	AU				
PRE	CO				
PRF	US				
PRG	CZ				PRG
PRH	TH				
PRI	SC				
PRJ	IT				
PRK	ZA				
PRL	US				
PRM	PT				
PRN	RS				PRN
PRO	US				
PRP	FR				
PRQ	AR				
PRR	GY				
PRS	SB				
PRT	US				
PRU	MM				
PRV	CZ				
PRW	US				
PRX	US				
PRY	ZA				
PRZ	US				
PSA	IT				PSA
PSB	US				
PSC	US				PSC
PSD	EG				
PSE	PR				
PSF	US				
PSG	US				PSG
PSH	DE				
PSI	PK				
PSJ	ID				
PSK	US				
PSL	GB				
PSN	US				
PSO	CO				PSO
PSP	US				PSP
PSR	IT				
PSS	AR				PSS
PST	CU				
PSU	ID				
PSV	GB				
PSW	BR				
PSX	US				
PSY	FK				
PSZ	BO				
PTA	US				
PTB	US				
PTC	US				
PTD	US				
PTE	AU				
PTF	FJ				
PTG	ZA				
PTH	US				
PTI	AU				
PTJ	AU				
PTK	US				
PTL	US				
PTM	VE				
PTN	US				
PTO	BR				
PTP	GP				PTP
PTQ	BR				
PTR	US				
PTS	US				
PTT	US				
PTU	US				
PTV	US				
PTW	US				
PTX	CO				
PTY	PA				PTY
PTZ	EC				
PUA	PG				
PUB	US				PUB
PUC	US				
PUD	AR				
PUE	PA				
PUF	FR				
PUG	AU				
PUH	MX				
PUI	PG				
PUJ	DO				PUJ
PUK	PF				
PUL	US				
PUM	ID				
PUN	ZR				
PUO	US				
PUP	BF				
PUQ	CL				PUQ
PUR	BO				
PUS	KR				PUS
PUT	IN				
PUU	CO				
PUV	NC				
PUW	US				PUW
PUX	CL				
PUY	HR				PUY
PUZ	NI				
PVA	CO				
PVC	US				
PVD	US				PVD
PVE	PA				
PVF	US				
PVH	BR				PVH
PVI	BR				
PVK	GR				PVK
PVN	BG				
PVO	EC				
PVR	MX				PVR
PVS	RU				
PVU	US				
PVW	US				
PVX	RU				
PVY	US				
PVZ	US				
PWD	US				
PWE	RU				
PWI	ET				
PWL	ID				
PWM	US				PWM
PWN	BS				
PWO	ZR				
PWQ	KZ				
PWR	US				
PWT	US				
PXL	US				
PXM	MX				
PXO	PT				PXO
PXU	VN				
PYA	CO				
PYB	IN				
PYC	PA				
PYE	CK				
PYH	VE				
PYJ	RU				
PYL	US				
PYM	US				
PYN	CO				
PYO	EC				
PYR	GR				
PYV	PA				
PYX	TH				
PZA	CO				
PZB	ZA				PZB
PZE	GB				
PZH	PK				
PZL	ZA				
PZO	VE				PZO
PZU	SD				
PZY	SK				
QAP	NG				
QBC	CA				
QFB	DE				
QGJ	BR				
QJU	IN				
QJY	PL				
QMZ	DE				
QNF	IN				
QNI	NG				
QPA	IT				
QRO	MX				QRO
QRW	NG				
QSR	IT				
QUF	EE				
QUL	DE				QUL
QWU	DE				QWU
QXZ	AT				
QYG	DE				
RAA	PG				
RAB	PG				
RAC	US				
RAE	SA				
RAG	NZ				
RAH	SA				
RAI	CV				RAI
RAJ	IN				RAJ
RAK	MA				RAK
RAL	US				
RAM	AU				
RAN	IT				
RAO	BR				RAO
RAP	US				RAP
RAQ	ID				
RAR	CK				RAR
RAS	IR				
RAT	RU				
RAU	BD				
RAV	CO				
RAW	PG				
RAX	PG				
RAY	GB				
RAZ	PK				
RBA	MA				
RBB	BR				
RBC	AU				
RBF	US				
RBG	US				
RBH	US				
RBI	FJ				
RBJ	JP				
RBK	US				
RBL	US				
RBM	DE				
RBN	US				
RBO	BO				
RBP	PG				
RBQ	BO				
RBR	BR				
RBS	AU				
RBT	KE				
RBU	AU				
RBW	US				
RBY	US				
RCB	ZA				RCB
RCE	US				
RCH	CO				RCH
RCK	US				
RCL	VU				
RCM	AU				
RCN	AU				
RCO	FR				
RCQ	AR				
RCR	US				
RCS	GB				
RCT	US				
RCU	AR				
RCY	BS				
RDA	AU				
RDB	US				
RDC	BR				
RDD	US				RDD
RDE	ID				
RDG	US				
RDM	US				RDM
RDR	US				
RDS	AR				
RDT	SN				
RDU	US				RDU
RDV	US				
RDZ	FR				
REA	PF				
REC	BR				REC
RED	US				
REG	IT				REG
REH	US				
REI	GF				
REK	IS				KEF
REL	AR				REL
REN	RU				
REO	US				
REP	KH				REP
RES	AR				RES
RET	NO				
REU	ES				
REW	IN				
REX	MX				
REY	BO				
RFA	CF				
RFD	US				
RFG	US				
RFK	US				
RFN	IS				
RFP	PF				
RFR	CR				
RGA	AR				
RGE	PG				
RGH	IN				
RGI	PF				
RGL	AR				RGL
RGN	MM				RGN
RGR	US				
RGT	ID				
RHA	IS				
RHD	AR				
RHE	FR				
RHG	RW				
RHI	US				
RHL	AU				
RHO	GR				RHO
RHP	NP				
RIA	BR				
RIB	BO				
RIC	US				RIC
RID	US				
RIE	US				
RIF	US				
RIG	BR				
RIJ	PE				
RIK	CR				
RIL	US				
RIM	PE				
RIN	SB				
RIO	BR				GIG, SDU
RIS	JP				RIS
RIT	PA				
RIW	US				RIW
RIX	LV				RIX
RIY	YE				
RIZ	PA				
RJA	IN				
RJB	NP				
RJH	BD				
RJI	IN				
RJK	HR				RJK
RKC	US				
RKD	US				
RKH	US				
RKI	ID				
RKO	ID				
RKP	US				
RKR	US				
RKS	US				RKS
RKT	AE				
RKU	PG				
RKW	US				
RKY	AU				
RLA	US				
RLD	US				
RLG	DE				RLG
RLK	CN				
RLP	AU				
RLT	NE				
RLU	US				
RMA	AU				
RMB	OM				
RMD	IN				
RME	US				
RMF	EG				RMF
RMG	US				
RMI	IT				RMI
RMK	AU				
RMN	PG				
RMP	US				
RMS	DE				
RNB	SE				RNB
RNC	US				
RNE	FR				
RNG	US				
RNH	US				
RNI	NI				
RNJ	JP				
RNL	SB				
RNN	DK				
RNO	US				RNO
RNP	MH				
RNR	PG				
RNS	FR				
RNT	US				
RNU	MY				
RNZ	US				
ROA	US				ROA
ROC	US				ROC
ROD	ZA				
ROG	US				
ROH	AU				
ROK	AU				
ROL	US				
ROM	IT				FCO
RON	CO				
ROO	BR				
ROP	MP				
ROR	PW				ROR
ROS	AR				ROS
ROT	NZ				ROT
ROU	BG				
ROV	RU				ROV
ROW	US				
ROX	US				
ROY	AR				
RPA	NP				
RPB	AU				
RPM	AU				
RPN	IL				
RPR	IN				RPR
RPV	AU				
RPX	US				
RRE	AU				
RRG	MU				
RRI	SB				
RRK	IN				
RRL	US				
RRM	MZ				
RRN	BR				
RRO	IT				
RRS	NO				
RRV	AU				
RSA	AR				
RSB	AU				
RSD	BS				
RSG	BR				
RSI	PA				
RSJ	US				
RSK	ID				
RSL	US				
RSN	US				
RSP	US				
RSS	SD				
RST	US				RST
RSU	KR				RSU
RSX	US				
RTA	FJ				
RTB	HN				RTB
RTC	IN				
RTD	US				
RTE	US				
RTG	ID				
RTI	ID				
RTL	US				
RTM	NL				RTM
RTN	US				
RTP	AU				
RTS	AU				
RTW	RU				
RTY	AU				
RUA	UG				
RUF	ID				
RUG	CN				
RUH	SA				RUH
RUI	US				
RUK	NP				
RUM	NP				
RUN	RE				
RUP	IN				
RUR	PF				
RUS	SB				
RUT	US				
RUU	PG				
RUV	GT				
RUY	HN				
RVA	MG				
RVC	LR				
RVD	BR				
RVE	CO				
RVK	NO				
RVN	FI				
RVO	ZA				
RVR	US				
RVY	UY				
RWB	US				
RWF	US				
RWI	US				
RWL	US				
RWN	UA				
RXA	YE				
RXS	PH				
RYB	RU				
RYK	PK				
RYN	FR				
RYO	AR				
RZA	AR				
RZE	PL				RZE
RZN	RU				
RZR	IR				
RZZ	US				
SAA	US				
SAB	AN				
SAC	US				SAC, SMF
SAD	US				
SAE	ID				
SAF	US				SAF
SAG	US				
SAH	YE				SAH
SAI	SM				
SAJ	BD				
SAK	IS				
SAL	SV				SAL
SAM	PG				
SAN	US				SAN
SAO	BR				CGH, GRU, VCP
SAP	HN				SAP
SAQ	BS				
SAR	US				
SAS	US				
SAT	US				SAT
SAU	ID				
SAV	US				SAV
SAX	PA				
SAY	IT				
SAZ	LR				
SBA	US				SBA
SBB	VE				
SBC	PG				
SBE	PG				
SBF	AF				
SBG	ID				
SBH	GP				
SBI	GN				
SBJ	BR				
SBK	FR				
SBL	BO				
SBM	US				
SBN	US				SBN
SBO	US				
SBQ	PK				
SBR	AU				
SBS	US				
SBT	US				
SBU	ZA				
SBV	PG				
SBW	MY				SBW
SBX	US				
SBY	US				SBY
SBZ	RO				SBZ
SCA	CO				
SCB	US				
SCC	US				SCC
SCD	HN				
SCE	US				SCE
SCG	AU				
SCH	US				
SCI	VE				
SCJ	US				
SCK	US				
SCL	CL				SCL
SCM	US				
SCN	DE				SCN, SDA
SCO	KZ				
SCP	FR				
SCQ	ES				SCQ
SCT	YE				
SCU	CU				
SCV	RO				
SCW	RU				SCW
SCX	MX				
SCY	EC				SCY
SCZ	SB				
SDB	ZA				
SDC	GY				
SDD	AO				
SDE	AR				
SDF	US				SDF
SDG	IR				
SDH	HN				
SDI	PG				
SDJ	JP				SDJ
SDK	MY				SDK
SDL	SE				SDL
SDN	NO				
SDO	JP				
SDP	US				
SDQ	DO				SDQ
SDR	ES				
SDS	JP				
SDT	PK				
SDW	BD				
SDX	US				
SDY	US				
SDZ	GB				
SEA	US				SEA
SEB	LY				
SEC	FR				
SED	IL				
SEF	US				
SEG	US				
SEH	ID				
SEI	BR				
SEJ	IS				
SEK	MA				
SEL	KR				GMP, ICN
SEN	GB				
SEO	CI				
SEP	US				
SEQ	ID				
SER	US				
SES	US				
SET	HN				
SEU	TZ				
SEV	UA				
SEW	EG				
SEX	DE				
SEY	MR				
SEZ	SC				SEZ
SFA	TN				
SFC	GP				
SFD	VE				
SFE	PH				
SFG	GP				
SFH	MX				
SFI	MA				
SFJ	GL				
SFK	BR				
SFL	CV				
SFM	US				
SFN	AR				SFN
SFO	US				SFO
SFP	AU				
SFQ	TR				GNY
SFR	US				
SFS	PH				
SFT	SE				SFT
SFU	PG				
SFV	BR				
SFW	PA				
SFX	VE				
SFZ	US				
SGA	AF				
SGB	PG				
SGC	RU				
SGD	DK				
SGE	DE				
SGF	US				SGF
SGG	MY				
SGH	US				
SGI	PK				
SGJ	PG				
SGK	PG				
SGM	MX				
SGN	VN				SGN
SGO	AU				
SGP	AU				
SGQ	ID				
SGS	PH				
SGT	US				
SGU	US				SGU
SGV	AR				
SGW	US				
SGX	TZ				
SGY	US				
SGZ	TH				
SHA	CN				PVG, SHA
SHB	JP				SHB
SHC	ET				SHC
SHD	US				
SHE	CN				SHE
SHF	CN				
SHG	US				
SHH	US				
SHI	JP				
SHJ	AE				SHJ
SHK	LS				
SHL	IN				SHL
SHM	JP				
SHN	US				
SHO	KR				
SHP	CN				
SHQ	AU				
SHR	US				SHR
SHS	CN				
SHT	AU				
SHU	AU				
SHV	US				DTN, SHV
SHW	SA				
SHX	US				
SHY	TZ				
SHZ	LS				
SIA	CN				SIA, XIY
SIB	CG				
SIC	TR				
SID	CV				SID
SIE	PT				
SIF	NP				
SIH	NP				
SII	MA				
SIJ	IS				
SIK	US				
SIL	PG				
SIM	PG				
SIN	SG				SIN
SIO	AU				
SIP	UA				
SIQ	ID				
SIR	CH				SIR
SIS	ZA				SIS
SIT	US				SIT
SIU	NI				
SIV	US				
SIW	ID				
SIX	AU				
SIY	US				
SIZ	PG				
SJA	PE				
SJB	BO				
SJC	US				SJC
SJD	MX				SJD
SJE	CO				
SJF	VI				
SJG	CO				
SJH	CO				
SJI	PH				
SJJ	BA				SJJ
SJK	BR				
SJL	BR				
SJM	DO				
SJN	US				
SJO	CR				SJO
SJP	BR				SJP
SJQ	ZM				
SJR	CO				
SJS	BO				
SJT	US				
SJU	PR				SJU
SJV	BO				
SJW	CN				SJW
SJX	BZ				
SJY	FI				
SJZ	PT				
SKB	KN				SKB
SKC	PG				
SKD	UZ				
SKE	NO				
SKG	GR				SKG
SKH	NP				
SKI	DZ				
SKJ	US				
SKK	US				
SKL	GB				
SKM	GY				
SKN	NO				
SKO	NG				
SKP	MK				SKP
SKQ	LS				
SKR	ET				
SKS	DK				
SKT	PK				
SKU	GR				
SKV	EG				
SKW	US				
SKX	RU				
SKY	US				
SKZ	PK				
SLA	AR				SLA
SLB	US				
SLC	US				SLC
SLD	SK				
SLE	US				
SLF	SA				
SLG	US				
SLH	VU				
SLI	ZM				
SLK	US				
SLL	OM				
SLM	ES				
SLN	US				
SLO	US				
SLP	MX				SLP
SLQ	US				
SLR	US				
SLS	BG				
SLT	US				
SLU	LC				UVF
SLV	IN				
SLW	MX				SLW
SLX	TC				
SLY	RU				
SLZ	BR				SLZ
SMA	PT				
SMB	CL				
SMC	CO				
SME	US				
SMG	PE				
SMH	PG				
SMI	GR				SMI
SMJ	PG				
SMK	US				
SML	BS				
SMM	MY				
SMN	US				
SMO	US				
SMP	PG				
SMQ	ID				
SMR	CO				SMR
SMS	MG				
SMT	TW				
SMU	US				
SMV	CH				
SMW	MA				
SMX	US				SMX
SMY	SN				
SMZ	SR				
SNA	US				SNA
SNB	AU				
SNC	EC				
SND	LA				
SNE	CV				
SNF	VE				
SNG	BO				
SNH	AU				
SNI	LR				
SNJ	CU				
SNK	US				
SNL	US				
SNM	BO				
SNN	IE				SNN
SNO	TH				
SNP	US				STT
SNQ	MX				
SNR	FR				
SNS	US				
SNT	CO				
SNU	CU				SNU
SNV	VE				
SNW	MM				
SNX	DO				
SNY	US				
SNZ	BR				
SOA	VN				
SOB	HU				
SOC	ID				SOC
SOD	BR				
SOE	CG				
SOF	BG				SOF
SOG	NO				
SOH	CO				
SOI	AU				
SOJ	NO				
SOK	LS				
SOL	US				
SOM	VE				
SON	VU				
SOO	SE				
SOP	US				
SOQ	ID				
SOR	SY				
SOT	FI				
SOU	GB				
SOV	US				
SOW	US				
SOX	CO				
SOY	GB				
SOZ	FR				
SPA	US				
SPC	ES				SPC
SPD	BD				
SPE	MY				
SPF	US				
SPH	PG				
SPI	US				SPI
SPJ	GR				
SPK	JP				CTS
SPM	DE				
SPN	MP				
SPO	ES				
SPP	AO				
SPQ	US				
SPR	BZ				
SPS	US				
SPT	MY				
SPU	HR				SPU
SPV	PG				
SPW	US				
SPY	CI				
SPZ	US				
SQA	US				
SQB	CO				
SQC	AU				
SQD	PE				
SQE	CO				
SQF	CO				
SQG	ID				
SQH	VN				
SQI	US				
SQJ	ET				
SQK	EG				
SQL	US				
SQM	BR				
SQN	ID				
SQO	SE				
SQP	AU				
SQQ	LT				
SQR	ID				
SQV	US				
SQZ	GB				
SRA	BR				
SRB	BO				
SRC	US				
SRD	BO				
SRE	BO				
SRF	US				
SRG	ID				SRG
SRH	TD				
SRI	ID				
SRJ	BO				
SRK	SL				
SRL	MX				
SRM	AU				
SRN	AU				
SRO	CO				
SRP	NO				
SRQ	US				SRQ
SRR	AU				
SRS	CO				
SRT	UG				
SRU	US				
SRV	US				
SRW	US				
SRX	LY				
SRY	IR				
SRZ	BO				VVI
SSA	BR				SSA
SSC	US				
SSD	CO				
SSE	IN				
SSG	GQ				SSG
SSH	EG				SSH
SSI	US				
SSK	AU				
SSL	CO				
SSM	US				
SSO	BR				
SSP	AU				
SSQ	CA				
SSR	VU				
SSS	PG				
SST	AR				
SSU	US				
SSV	PH				
SSW	US				
SSY	AO				
SSZ	BR				
STA	DK				
STB	VE				
STC	US				
STD	VE				
STE	US				
STF	AU				
STG	US				
STH	AU				
STI	DO				STI
STJ	US				
STK	US				
STL	US				STL
STM	BR				
STO	SE				ARN, BMA
STQ	US				
STR	DE				STR, ZWS
STS	US				STS
STT	VI				
STU	BZ				
STV	IN				STV
STW	RU				STW
STX	VI				
STY	UY				
STZ	BR				
SUA	US				
SUB	ID				SUB
SUC	US				
SUD	US				
SUE	US				
SUF	IT				SUF
SUG	PH				
SUH	OM				
SUI	GE				
SUJ	RO				
SUK	KR				
SUL	PK				
SUN	US				SUN
SUO	US				
SUP	ID				
SUQ	EC				
SUR	CA				
SUT	TZ				
SUU	US				
SUV	FJ				
SUW	US				
SUX	US				
SUY	IS				
SUZ	PG				
SVA	US				
SVB	MG				
SVC	US				
SVD	VC				
SVE	US				
SVF	BJ				
SVG	NO				SVG
SVH	US				
SVI	CO				
SVJ	NO				
SVK	BZ				
SVL	FI				
SVM	AU				
SVP	AO				
SVQ	ES				SVQ
SVR	KH				
SVS	US				
SVT	BW				
SVU	FJ				
SVV	VE				
SVW	US				
SVX	RU				SVX
SVY	SB				
SVZ	VE				SVZ
SWA	CN				SWA
SWB	AU				
SWC	AU				
SWD	US				
SWE	PG				
SWF	US				
SWG	PG				
SWH	AU				
SWI	GB				
SWJ	VU				
SWL	BS				
SWM	BR				
SWN	PK				
SWO	US				
SWP	NA				
SWQ	ID				
SWR	PG				
SWS	GB				
SWT	RU				
SWU	KR				
SWV	PK				
SWW	US				
SWX	BW				
SWY	MY				
SXA	PG				
SXB	FR				SXB, XER
SXD	FR				
SXE	AU				
SXG	ZM				
SXH	PG				
SXI	IR				
SXJ	CN				
SXK	ID				
SXL	IE				
SXM	SX				SXM
SXN	BW				
SXO	BR				
SXP	US				
SXQ	US				
SXR	IN				SXR
SXS	MY				
SXT	MY				
SXU	ET				
SXV	IN				
SXW	PG				
SXX	BR				
SXY	US				
SXZ	TR				
SYA	US				
SYB	US				
SYC	PE				
SYD	AU				SYD
SYE	YE				
SYF	CA				
SYH	NP				
SYI	US				
SYK	IS				
SYL	US				
SYM	CN				
SYN	US				
SYO	JP				SYO
SYP	PA				
SYR	US				SYR
SYS	KR				
SYT	FR				
SYU	AU				
SYV	US				
SYX	CN				SYX
SYY	GB				
SYZ	IR				SYZ
SZA	AO				
SZC	CR				
SZD	GB				
SZF	TR				SZF
SZG	AT				SZG, ZSB
SZH	ID				
SZK	ZA				SZK
SZL	US				
SZO	CN				
SZP	US				
SZQ	AR				
SZR	BG				
SZS	NZ				
SZU	ML				
SZV	CN				
SZW	DE				
SZX	CN				SZX
SZZ	PL				SZZ
TAA	SB				
TAB	TT				TAB
TAC	PH				
TAD	US				
TAE	KR				TAE
TAG	PH				
TAH	VU				
TAI	YE				
TAK	JP				TAK
TAL	US				
TAM	MX				TAM
TAN	AU				
TAO	CN				TAO
TAP	MX				
TAQ	AU				
TAR	IT				
TAS	UZ				TAS
TAT	SK				
TAU	CO				
TAV	AS				
TAW	UY				
TAX	ID				
TAY	EE				
TAZ	TM				
TBA	PG				
TBB	VN				
TBC	US				
TBD	CO				
TBE	PG				
TBF	KI				
TBG	PG				
TBH	PH				
TBI	BS				
TBJ	TN				
TBK	AU				
TBL	AU				
TBM	ID				
TBO	TZ				
TBP	PE				
TBQ	PG				
TBR	US				
TBS	GE				TBS
TBT	BR				
TBU	TO				TBU
TBV	MH				
TBW	RU				
TBX	CI				
TBY	BW				
TBZ	IR				TBZ
TCA	AU				
TCB	BS				
TCC	US				
TCD	CO				
TCE	RO				
TCF	HN				
TCG	CN				
TCH	GA				
TCI	ES				TFS
TCL	US				
TCN	MX				
TCO	CO				
TCQ	PE				
TCS	US				
TCT	US				
TCU	ZA				
TCW	AU				
TCZ	CN				TCZ
TDA	CO				
TDB	PG				
TDD	BO				
TDG	PH				
TDJ	DJ				
TDK	KZ				
TDL	AR				
TDO	US				
TDR	AU				
TDT	ZA				
TDV	MG				
TDX	TH				
TEA	HN				
TEB	US				
TEC	BR				
TED	DK				
TEE	DZ				
TEF	AU				
TEG	BF				
TEH	US				
TEI	IN				
TEK	US				
TEL	MY				
TEM	AU				
TEN	CN				
TEO	PG				
TEP	PG				
TEQ	TR				
TER	PT				TER
TES	ER				
TET	MZ				TET
TEU	NZ				
TEX	US				
TEY	IS				
TEZ	IN				TEZ
TFA	PG				
TFF	BR				
TFI	PG				
TFL	BR				
TFM	PG				
TFT	PK				
TFY	MA				
TGB	PH				
TGD	ME				TGD
TGE	US				
TGF	FR				
TGG	MY				TGG
TGH	VU				
TGI	PE				
TGJ	NC				
TGL	PG				
TGM	RO				
TGN	AU				
TGO	CN				TGO
TGR	DZ				
TGS	MZ				
TGT	TZ				
TGU	HN				TGU
TGV	BG				
TGX	CI				
TGZ	MX				TGZ
THA	US				
THB	LS				
THC	LR				
THE	BR				THE
THG	AU				
THH	NZ				
THI	MR				
THK	LA				
THL	MM				
THM	US				
THN	SE				
THO	IS				
THP	US				
THR	IR				IKA
THS	TH				THS
THT	MR				
THU	GL				
THV	US				
THY	ZA				
THZ	NE				
TIA	AL				TIA
TIB	CO				
TIC	MH				
TID	DZ				
TIE	ET				
TIF	SA				
TIG	PG				
TIH	PF				
TII	AF				
TIJ	MX				TIJ
TIL	CA				
TIM	ID				
TIN	DZ				
TIO	MM				
TIP	LY				
TIQ	MP				
TIR	IN				TIR
TIS	AU				
TIU	NZ				
TIV	ME				TIV
TIW	US				
TIX	US				
TIY	MR				
TIZ	PG				
TJA	BO				
TJB	ID				
TJG	ID				
TJH	JP				
TJI	HN				
TJM	RU				
TJQ	ID				
TJS	ID				
TJV	IN				
TKA	US				
TKB	PG				
TKC	CM				
TKD	GH				
TKE	US				
TKF	US				
TKG	ID				
TKH	TH				
TKI	US				
TKJ	US				
TKK	FM				TKK
TKL	US				
TKM	GT				
TKN	JP				
TKO	LS				
TKP	PF				
TKQ	TZ				
TKR	BD				
TKS	JP				TKS
TKT	TH				
TKU	FI				TKU
TKV	PF				
TKW	PG				
TKX	PF				
TKY	AU				
TKZ	NZ				
TLA	US				
TLB	PK				
TLC	MX				
TLD	BW				
TLE	MG				
TLF	US				
TLG	SB				
TLH	US				TLH
TLI	ID				
TLJ	US				
TLK	IS				
TLL	EE				TLL
TLM	DZ				
TLN	FR				TLN
TLO	PG				
TLP	PG				
TLR	US				
TLS	FR				TLS
TLT	US				
TLU	CO				
TLV	IL				TLV
TLW	PG				
TLX	CL				
TLZ	BR				
TMA	US				
TMC	ID				
TMD	MR				
TME	CO				
TMG	MY				
TMH	ID				
TMI	NP				
TMK	VN				
TML	GH				
TMM	MG				
TMN	KI				
TMO	VE				
TMP	FI				TMP
TMQ	BF				
TMR	DZ				
TMS	ST				TMS
TMT	BR				
TMU	CR				
TMW	AU				
TMX	DZ				
TMY	ID				
TMZ	NZ				
TNA	CN				TNA
TNB	ID				
TNC	US				
TND	CU				
TNE	JP				
TNF	FR				
TNG	MA				TNG
TNH	CN				TNH
TNI	IN				
TNJ	ID				
TNK	US				
TNL	UA				
TNM	AQ				
TNN	TW				
TNO	CR				
TNP	US				
TNQ	KI				
TNR	MG				TNR
TNS	CA				
TNU	US				
TNV	KI				
TNX	KH				
TOA	US				
TOB	LY				
TOC	US				
TOD	MY				
TOE	TN				
TOF	RU				TOF
TOG	US				
TOH	VU				
TOI	US				
TOK	PG				
TOL	US				
TOM	ML				
TON	PG				
TOP	US				FOE, TOP
TOQ	CL				
TOR	US				
TOS	NO				TOS
TOT	SR				
TOU	NC				
TOV	VG				
TOW	BR				
TOX	RU				
TOY	JP				TOY
TOZ	CI				
TPA	US				TPA
TPC	EC				
TPE	TW				TSA, TPE
TPG	MY				
TPH	US				
TPI	PG				
TPJ	NP				
TPK	ID				
TPL	US				
TPN	EC				
TPO	US				
TPP	PE				
TPQ	MX				
TPR	AU				
TPS	IT				
TPT	LR				
TPU	NP				
TQN	AF				
TQS	CO				
TRA	JP				
TRB	CO				
TRC	MX				TRC
TRD	NO				TRD
TRE	GB				
TRF	NO				
TRG	NZ				TRG
TRH	US				
TRI	US				
TRJ	PG				
TRK	ID				
TRL	US				
TRM	US				
TRN	IT				TRN
TRO	AU				
TRP	US				
TRQ	BR				
TRR	LK				
TRS	IT				TRS
TRT	US				
TRU	PE				TRU
TRV	IN				TRV
TRW	KI				
TRX	US				
TRY	UG				
TRZ	IN				TRZ
TSB	NA				
TSC	EC				
TSD	ZA				
TSE	KZ				TSE
TSG	US				
TSH	ZR				
TSI	PG				
TSJ	JP				TSJ
TSK	PG				
TSL	MX				
TSM	US				
TSN	CN				TSN
TSP	US				
TSR	RO				TSR
TST	TH				
TSU	KI				
TSV	AU				
TSW	PG				
TSX	ID				
TSY	ID				
TSZ	MN				
TTA	MA				
TTB	IT				
TTC	CL				
TTD	US				
TTE	ID				
TTG	AR				
TTH	OM				
TTI	PF				
TTJ	JP				TTJ
TTK	GB				
TTL	FJ				
TTM	CO				
TTN	US				
TTO	US				TRI
TTQ	CR				
TTR	ID				
TTS	MG				
TTT	TW				
TTU	MA				
TUA	EC				
TUB	PF				
TUC	AR				TUC
TUD	SN				
TUE	PA				
TUF	FR				
TUG	PH				
TUI	SA				
TUJ	ET				
TUK	PK				
TUL	US				TUL
TUM	AU				
TUN	TN				TUN
TUO	NZ				TUO
TUP	US				
TUQ	BF				
TUR	BR				
TUS	US				TUS
TUT	PG				
TUU	SA				
TUV	VE				
TUW	PA				
TUX	CA				
TUY	MX				
TUZ	BR				
TVA	MG				
TVC	US				TVC
TVF	US				
TVI	US				
TVL	US				
TVU	FJ				
TVY	MM				
TWA	US				
TWB	AU				
TWD	US				
TWE	US				
TWF	US				
TWN	AU				
TWP	AU				
TWT	PH				
TWU	MY				TWU
TWY	PG				
TXG	TW				TXG
TXK	US				
TXM	ID				
TXN	CN				TXN
TXR	AU				
TXU	CI				
TYA	RU				
TYB	AU				
TYD	RU				
TYE	US				
TYF	SE				
TYG	AU				
TYL	PE				
TYM	BS				
TYN	CN				TYN
TYO	JP				HND, NRT
TYP	AU				
TYR	US				TYR
TYS	US				TYS
TYT	UY				
TYZ	US				
TZM	MX				
TZN	BS				
TZX	TR				TZX
UAC	MX				
UAE	PG				
UAH	PF				
UAI	ID				
UAK	GL				
UAL	AO				
UAP	PF				
UAQ	AR				
UAS	KE				
UAX	GT				
UBA	BR				
UBB	AU				
UBI	PG				
UBJ	JP				UBJ
UBP	TH				UBP
UBR	ID				
UBS	US				
UBT	BR				
UBU	AU				
UCA	US				
UCC	US				
UCE	US				
UCK	UA				
UCN	LR				
UCT	RU				
UCY	US				
UCZ	PE				
UDA	AU				
UDE	NL				
UDI	BR				UDI
UDJ	UA				
UDN	IT				
UDO	LA				
UDR	IN				UDR
UEE	AU				
UEL	MZ				
UEO	JP				
UES	US				
UET	PK				
UFA	RU				UFA
UGA	MN				
UGC	UZ				
UGI	US				
UGN	US				
UGO	AO				
UGS	US				
UGU	ID				
UHE	CZ				
UHF	GB				
UIB	CO				
UIH	VN				
UII	HN				
UIK	RU				
UIL	US				
UIN	US				
UIO	EC				UIO
UIP	FR				
UIQ	VU				
UIR	AU				
UIT	MH				
UIZ	US				
UJE	MH				
UKB	JP				
UKI	US				
UKK	KZ				
UKN	US				
UKR	YE				
UKT	US				
UKU	PG				
UKX	RU				
UKY	JP				
ULA	AR				
ULB	VU				
ULD	ZA				
ULE	PG				
ULG	MN				
ULI	FM				
ULL	GB				
ULM	US				
ULN	MN				ULN
ULO	MN				
ULP	AU				
ULQ	CO				
ULS	CO				
ULU	UG				
ULX	ZA				
ULY	RU				ULY
ULZ	MN				
UMA	CU				
UMB	US				
UMC	PG				
UMD	GL				
UME	SE				UME
UMI	PE				
UMM	US				
UMR	AU				
UMT	US				
UMU	BR				
UMY	UA				
UNA	BR				
UNC	CO				
UND	AF				
UNE	LS				
UNG	PG				
UNI	VC				
UNK	US				
UNN	TH				
UNR	MN				
UNS	US				
UNT	GB				
UNU	US				
UOL	ID				
UON	LA				
UOS	US				
UOX	US				
UPA	CU				
UPC	ES				
UPF	DE				
UPG	ID				UPG
UPL	CR				
UPN	MX				
UPP	US				
UPR	PG				
UPV	GB				
UQE	US				
URA	KZ				
URB	BR				
URC	CN				URC
URE	EE				
URG	BR				
URI	CO				
URJ	RU				
URM	VE				
URN	AF				
URO	FR				
URR	CO				
URS	RU				
URT	TH				URT
URY	SA				
URZ	AF				
USH	AR				USH
USI	GY				
USK	RU				USK
USL	AU				
USM	TH				USM
USN	KR				USN
USO	PG				
USS	CU				
UST	US				
USU	PH				
UTA	ZW				
UTB	AU				
UTC	NL				
UTD	AU				
UTE	ZA				
UTG	LS				
UTH	TH				UTH
UTI	FI				
UTK	MH				
UTL	ES				
UTN	ZA				UTN
UTO	US				
UTP	TH				
UTR	TH				
UTT	ZA				PTG, UTT
UTU	PA				
UTW	ZA				
UUA	RU				
UUD	RU				
UUK	US				
UUN	MN				
UUS	RU				UUS
UUU	PG				
UVA	US				
UVE	NC				
UVL	EG				
UVO	PG				
UWA	US				
UWE	DE				
UYL	SD				
UYN	CN				
UZH	SA				
UZU	AR				
VAA	FI				VAA
VAB	CO				
VAC	DE				
VAF	FR				
VAG	BR				
VAH	BO				
VAI	PG				
VAK	US				
VAL	BR				
VAN	TR				VAN
VAO	SB				
VAP	CL				
VAR	BG				VAR
VAS	TR				VAS
VAT	MG				
VAU	FJ				
VAV	TO				
VAW	NO				
VAZ	FR				
VBS	IT				
VBV	FJ				
VBY	SE				VBY
VCA	VN				
VCB	US				
VCC	CM				
VCD	AU				
VCE	IT				VCE
VCF	AR				
VCH	UY				
VCR	VE				
VCT	US				VCT
VCV	US				
VDA	IL				VDA
VDB	NO				
VDC	BR				
VDE	ES				
VDI	US				
VDM	AR				
VDP	VE				
VDR	AR				
VDS	NO				
VDZ	US				
VEE	US				
VEG	GY				
VEJ	DK				
VEL	US				VEL
VER	MX				VER
VEV	SB				
VEX	US				
VEY	IS				
VFA	ZW				VFA
VGA	IN				VGA
VGD	RU				
VGG	LA				
VGO	ES				VGO
VGS	AR				
VGZ	CO				
VHC	AO				
VHM	SE				
VHN	US				
VHY	FR				
VHZ	PF				
VIB	MX				
VIC	IT				
VID	BG				
VIE	AT				VIE
VIG	VE				
VIH	US				
VII	VN				
VIJ	VG				
VIK	US				
VIL	MA				
VIN	UA				
VIQ	ID				
VIS	US				
VIT	ES				
VIU	SB				
VIV	PG				
VIX	BR				VIX
VJB	MZ				
VJI	US				
VJQ	MZ				
VKG	VN				
VKS	US				
VKT	RU				
VKW	US				
VLA	US				
VLC	ES				VLC
VLD	US				
VLE	US				
VLG	AR				
VLI	VU				
VLK	RU				
VLL	ES				
VLM	BO				
VLN	VE				VLN
VLO	US				
VLP	BR				
VLR	CL				
VLS	VU				
VLU	RU				
VLV	VE				
VME	AR				
VMU	PG				
VNA	LA				
VNC	US				
VNE	FR				
VNG	LA				
VNO	LT				VNO
VNR	AU				
VNS	IN				VNS
VNX	MZ				VNX
VOG	RU				VOG
VOH	MG				
VOI	LR				
VOK	US				
VOL	GR				VOL
VOT	BR				
VOZ	RU				VOZ
VPE	AO				
VPN	IS				
VPS	US				VPS
VPY	MZ				
VPZ	US				
VQS	PR				
VRA	CU				VRA
VRB	US				
VRC	PH				
VRE	ZA				
VRK	FI				
VRL	PT				
VRN	IT				VRN
VRS	US				
VRU	ZA				
VRY	NO				
VSA	MX				VSA
VSE	PT				
VSF	US				
VSG	UA				
VSO	VN				
VST	SE				
VTA	HN				
VTB	BY				
VTE	LA				VTE
VTF	FJ				
VTG	VN				
VTL	FR				
VTN	US				
VTU	CU				
VTZ	IN				VTZ
VUP	CO				
VUS	RU				
VVB	MG				
VVC	CO				
VVK	SE				
VVO	RU				VVO
VVZ	DZ				
VXC	MZ				
VXE	CV				VXE
VXO	SE				
VYD	ZA				
VYS	US				
WAA	US				
WAB	PG				
WAC	ET				
WAD	MG				
WAE	SA				
WAF	PK				
WAG	NZ				WAG
WAH	US				
WAI	MG				
WAJ	PG				
WAK	MG				
WAL	US				
WAM	MG				
WAN	AU				
WAO	PG				
WAP	CL				
WAQ	MG				
WAR	ID				
WAS	US				DCA, IAD
WAT	IE				
WAU	AU				
WAV	AU				
WAW	PL				WAW
WAY	US				
WAZ	AU				
WBB	US				
WBD	MG				
WBE	MG				
WBM	PG				
WBN	US				
WBO	MG				
WBQ	US				
WBR	US				
WBU	US				
WCA	CL				
WCH	CL				
WCR	US				
WDA	YE				
WDB	US				
WDG	US				
WDH	NA				WDH
WDI	AU				
WDN	US				
WDR	US				
WEA	US				
WED	PG				
WEF	CN				
WEH	CN				WEH
WEI	AU				
WEL	ZA				
WEM	GB				
WEP	PG				
WES	LR				
WET	ID				
WEW	AU				
WEX	IE				
WFI	MG				
WFK	US				
WGA	AU				
WGB	PK				
WGC	IN				
WGE	AU				
WGN	NZ				
WGO	US				
WGP	ID				
WGT	AU				
WGU	PG				
WGY	GA				
WHD	US				
WHF	SD				
WHK	NZ				
WHL	AU				
WHO	NZ				
WHS	GB				
WHT	US				
WHU	CN				
WIC	GB				
WID	DE				
WIK	NZ				
WIN	AU				
WIO	AU				
WIR	NZ				
WIT	AU				
WIU	PG				
WJA	MH				
WJF	US				
WJR	KE				
WKA	NZ				
WKB	AU				
WKI	ZW				
WKJ	JP				WKJ
WKK	US				
WKL	US				
WKN	PG				
WKR	BS				
WLA	AU				
WLB	US				
WLC	AU				
WLD	US				
WLG	NZ				WLG
WLH	VU				
WLK	US				
WLL	AU				
WLM	US				
WLN	US				
WLO	AU				
WLR	US				
WLS	WF				
WLW	US				
WMA	MG				
WMB	AU				
WMC	US				
WMD	MG				
WME	AU				
WMH	US				
WMK	US				
WML	MG				
WMN	MG				
WMO	US				
WMR	MG				
WMV	MG				
WMX	ID				
WNA	US				
WNC	US				
WND	AU				
WNE	GA				
WNN	CA				
WNP	PH				
WNR	AU				
WNS	PK				
WNU	PG				
WNZ	CN				WNZ
WOA	PG				
WOB	GB				
WOD	US				
WOE	NL				
WOG	AU				
WOI	LR				
WOK	VE				
WOL	AU				
WON	AU				
WOO	US				
WOT	TW				
WOW	US				
WPA	CL				
WPB	MG				
WPC	CA				
WPK	AU				
WPL	CA				
WPM	PG				
WPO	US				
WPR	CL				
WPU	CL				
WRA	ET				
WRE	NZ				WRE
WRG	US				WRG
WRH	US				
WRI	US				
WRL	US				WRL
WRO	PL				WRO
WRW	AU				
WRY	GB				
WSA	PG				
WSB	US				
WSD	US				
WSF	US				
WSG	US				
WSH	US				
WSJ	US				
WSM	US				
WSN	US				
WSO	SR				
WSP	NI				
WSR	ID				
WST	US				
WSU	PG				
WSX	US				
WSY	AU				
WSZ	NZ				
WTA	MG				
WTD	BS				
WTE	MH				
WTK	US				
WTL	US				
WTN	GB				
WTO	MH				
WTP	PG				
WTR	US				
WTS	MG				
WTT	PG				
WTZ	NZ				
WUA	CN				
WUD	AU				
WUG	PG				
WUH	CN				WUH
WUN	AU				
WUS	CN				
WUU	SD				
WUV	PG				
WUX	CN				WUX
WUZ	CN				
WVB	NA				WVB
WVI	US				
WVK	MG				
WVL	US				
WVN	DE				
WWA	US				
WWD	US				
WWI	AU				
WWK	PG				
WWP	US				
WWR	US				
WWS	US				
WWT	US				
WWY	AU				
WXF	GB				
WXN	CN				WXN
WYA	AU				
WYB	US				
WYE	SL				
WYN	AU				
WYS	US				
XAL	MX				
XAP	BR				XAP
XAR	BF				
XAU	GF				
XAY	LA				
XBB	CA				
XBE	CA				
XBG	BF				
XBJ	IR				
XBL	ET				
XBN	PG				
XBO	BF				
XBR	CA				
XBW	CA				
XCH	CX				
XCL	CA				
XCM	CA				
XCN	PH				
XCO	AU				
XDE	BF				
XDJ	BF				
XEN	CN				
XES	US				
XFN	CN				XFN
XFW	DE				
XGA	BF				
XGG	BF				
XGL	CA				
XGN	AO				
XGR	CA				
XIC	CN				XIC
XIE	LA				
XIG	BR				
XIL	CN				XIL
XIN	CN				
XKA	BF				
XKH	LA				
XKO	CA				
XKS	CA				
XKY	BF				
XLB	CA				
XLF	CA				
XLJ	CA				
XLM	CA				
XLO	VN				
XLS	SN				
XLU	BF				
XLW	DE				
XMA	PH				
XMB	CI				
XMC	AU				
XMD	US				
XMG	NP				
XMH	PF				
XMI	TZ				
XML	AU				
XMN	CN				XMN
XMP	CA				
XMS	EC				
XMY	AU				
XNG	VN				
XNN	CN				XNN
XNT	CN				
XNU	BF				
XPA	BF				
XPK	CA				
XPL	HN				
XPP	CA				
XPR	US				
XPU	US				
XQP	CR				
XQU	CA				
XRR	CA				
XRY	ES				XRY
XSC	TC				
XSE	BF				
XSH	FR				
XSI	CA				
XSM	US				
XSO	PH				
XTG	AU				
XTL	CA				
XTO	AU				
XTR	AU				
XUZ	CN				XUZ
XVL	VN				
XXB	IN				
XXP	DE				
XYA	SB				
XYE	MM				
XYR	PG				
XZA	BF				
YAA	CA				
YAB	CA				
YAC	CA				
YAD	CA				
YAE	CA				
YAF	CA				
YAG	CA				
YAI	CL				
YAJ	CA				
YAK	US				YAK
YAL	CA				
YAM	CA				YAM
YAN	ZR				
YAO	CM				NSI, YAO
YAP	FM				YAP
YAQ	CA				
YAS	FJ				
YAT	CA				
YAV	CA				
YAX	CA				
YAY	CA				
YAZ	CA				
YBA	CA				
YBC	CA				YBC
YBD	CA				
YBE	CA				
YBF	CA				
YBG	CA				YBG
YBH	CA				
YBI	CA				
YBJ	CA				
YBK	CA				
YBL	CA				YBL
YBM	CA				
YBN	CA				
YBO	CA				
YBP	CN				
YBQ	CA				
YBR	CA				
YBT	CA				
YBV	CA				
YBW	CA				
YBX	CA				
YBY	CA				
YCA	CA				
YCB	CA				
YCC	CA				
YCD	CA				YCD
YCE	CA				
YCF	CA				
YCG	CA				YCG
YCH	CA				
YCI	CA				
YCJ	CA				
YCK	CA				
YCL	CA				
YCM	CA				
YCN	CA				
YCO	CA				
YCP	CA				
YCQ	CA				
YCR	CA				
YCS	CA				
YCT	CA				
YCU	CA				YCU
YCV	CA				
YCW	CA				
YCX	CA				
YCY	CA				
YCZ	CA				
YDA	CA				
YDB	CA				
YDC	CA				
YDE	CA				
YDF	CA				YDF
YDG	CA				
YDH	CA				
YDI	CA				
YDK	CA				
YDL	CA				
YDN	CA				
YDO	CA				
YDP	CA				
YDQ	CA				
YDR	CA				
YDS	CA				
YDV	CA				
YDX	CA				
YEA	CA				YEG
YEC	KR				
YEI	TR				
YEK	CA				
YEL	CA				
YEM	CA				
YEN	CA				
YEO	GB				
YEP	CA				
YEQ	PG				
YER	CA				
YET	CA				
YEU	CA				
YEV	CA				
YEY	CA				
YFA	CA				
YFB	CA				YFB
YFC	CA				YFC
YFE	CA				
YFG	CA				
YFH	CA				
YFL	CA				
YFO	CA				
YFR	CA				
YFS	CA				
YFX	CA				
YGA	CA				
YGB	CA				
YGC	CA				
YGE	CA				
YGG	CA				
YGH	CA				
YGJ	JP				YGJ
YGK	CA				YGK
YGL	CA				
YGM	CA				
YGN	CA				
YGO	CA				
YGP	CA				YGP
YGQ	CA				
YGR	CA				YGR
YGS	CA				
YGT	CA				
YGV	CA				
YGW	CA				
YGX	CA				
YGY	CA				
YGZ	CA				
YHA	CA				
YHB	CA				
YHC	CA				
YHD	CA				
YHE	CA				
YHF	CA				
YHG	CA				
YHI	CA				
YHK	CA				
YHM	CA				
YHN	CA				
YHO	CA				
YHP	CA				
YHR	CA				
YHS	CA				
YHT	CA				
YHY	CA				
YHZ	CA				YHZ
YIB	CA				
YIC	CA				
YIF	CA				
YIG	CA				
YIH	CN				YIH
YIK	CA				
YIN	CN				YIN
YIO	CA				
YIV	CA				
YIW	CN				YIW
YIX	CA				
YJA	CA				
YJF	CA				
YJN	CA				
YJO	CA				
YJT	CA				
YKA	CA				YKA
YKC	CA				
YKD	CA				
YKE	CA				
YKF	CA				
YKG	CA				
YKI	CA				
YKJ	CA				
YKK	CA				
YKL	CA				
YKM	US				YKM
YKN	US				
YKQ	CA				
YKS	RU				
YKT	CA				
YKU	CA				
YKX	CA				
YKY	CA				
YLB	CA				
YLC	CA				
YLD	CA				
YLE	CA				
YLF	CA				
YLG	AU				
YLH	CA				
YLI	FI				
YLJ	CA				
YLL	CA				
YLM	CA				
YLN	CN				
YLP	CA				
YLQ	CA				
YLR	CA				
YLS	CA				
YLT	CA				
YLW	CA				YLW
YLX	CA				
YLY	CA				
YMA	CA				
YMB	CA				
YMC	CA				
YMD	CA				
YME	CA				
YMF	CA				
YMG	CA				
YMH	CA				
YMI	CA				
YMJ	CA				
YML	CA				
YMM	CA				YMM
YMN	CA				
YMO	CA				
YMP	CA				
YMQ	CA				YUL
YMR	CA				
YMS	PE				
YMT	CA				
YMW	CA				
YNA	CA				
YNB	SA				YNB
YNC	CA				
YND	CA				
YNE	CA				
YNG	US				
YNH	CA				
YNI	CA				
YNJ	CN				YNJ
YNK	CA				
YNL	CA				
YNM	CA				
YNO	CA				
YNR	CA				
YNS	CA				
YNT	CN				YNT
YNZ	CN				YNZ
YOC	CA				
YOD	CA				
YOE	CA				
YOG	CA				
YOH	CA				
YOJ	CA				
YOK	JP				
YOL	NG				
YOO	CA				
YOP	CA				
YOS	CA				
YOW	CA				YOW
YOY	CA				
YPA	CA				
YPB	CA				
YPC	CA				
YPD	CA				
YPE	CA				
YPF	CA				
YPG	CA				
YPH	CA				
YPI	CA				
YPJ	CA				
YPL	CA				
YPM	CA				
YPN	CA				
YPO	CA				
YPP	CA				
YPQ	CA				
YPR	CA				YPR
YPT	CA				
YPW	CA				
YPX	CA				
YPY	CA				
YPZ	CA				
YQA	CA				
YQB	CA				YQB
YQC	CA				
YQD	CA				
YQE	CA				
YQF	CA				
YQG	CA				YQG
YQH	CA				
YQI	CA				
YQK	CA				
YQL	CA				YQL
YQM	CA				YQM
YQN	CA				
YQQ	CA				YQQ
YQR	CA				YQR
YQS	CA				
YQT	CA				YQT
YQU	CA				YQU
YQV	CA				
YQW	CA				
YQX	CA				YQX
YQY	CA				YQY
YQZ	CA				YQZ
YRA	CA				
YRB	CA				
YRD	CA				
YRE	CA				
YRF	CA				
YRG	CA				
YRI	CA				
YRJ	CA				
YRL	CA				
YRM	CA				
YRN	CA				
YRQ	CA				
YRR	CA				
YRS	CA				
YRT	CA				
YRV	CA				
YSA	CA				
YSB	CA				YSB
YSC	CA				
YSD	CA				
YSE	CA				
YSF	CA				
YSG	CA				
YSH	CA				
YSI	CA				
YSJ	CA				YSJ
YSK	CA				
YSL	CA				
YSM	CA				
YSN	CA				
YSO	CA				
YSP	CA				
YSQ	CA				
YSR	CA				
YSS	CA				
YST	CA				
YSU	CA				
YSV	CA				
YSX	CA				
YSY	CA				
YSZ	CA				
YTA	CA				
YTB	CA				
YTC	CA				
YTD	CA				
YTE	CA				
YTF	CA				
YTG	CA				
YTH	CA				
YTI	CA				
YTJ	CA				
YTK	CA				
YTL	CA				
YTN	CA				
YTO	CA				YHM, YTZ, YYZ
YTQ	CA				
YTR	CA				
YTS	CA				YTS
YTT	CA				
YTU	CA				
YTX	CA				
YTY	CN				YTY
YUA	CN				
YUB	CA				
YUD	CA				
YUE	AU				
YUF	CA				
YUJ	CA				
YUM	US				
YUN	CA				
YUT	CA				
YUX	CA				
YUY	CA				YUY
YVA	KM				HAH
YVB	CA				
YVC	CA				
YVD	PG				
YVE	CA				
YVG	CA				
YVM	CA				
YVN	CA				
YVO	CA				YVO
YVP	CA				
YVQ	CA				
YVR	CA				YVR
YVT	CA				
YVV	CA				
YVZ	CA				
YWA	CA				
YWB	CA				
YWG	CA				YWG
YWJ	CA				
YWK	CA				YWK
YWL	CA				YWL
YWM	CA				
YWN	CA				
YWP	CA				
YWR	CA				
YWS	CA				
YWY	CA				
YXC	CA				YXC
YXE	CA				YXE
YXF	CA				
YXH	CA				YXH
YXI	CA				
YXJ	CA				YXJ
YXK	CA				
YXL	CA				
YXN	CA				
YXP	CA				
YXQ	CA				
YXR	CA				
YXS	CA				YXS
YXT	CA				YXT
YXU	CA				YXU
YXX	CA				YXX
YXY	CA				YXY
YXZ	CA				
YYA	CA				
YYB	CA				YYB
YYC	CA				YYC
YYD	CA				YYD
YYE	CA				
YYF	CA				YYF
YYG	CA				YYG
YYH	CA				
YYI	CA				
YYJ	CA				YYJ
YYL	CA				
YYM	CA				
YYN	CA				
YYQ	CA				
YYR	CA				YYR
YYT	CA				YYT
YYU	CA				
YYW	CA				
YYY	CA				YYY
YZA	CA				
YZC	CA				
YZE	CA				
YZF	CA				YZF
YZG	CA				
YZH	CA				
YZL	CA				
YZM	CA				
YZP	CA				YZP
YZR	CA				YZR
YZS	CA				
YZT	CA				
YZU	CA				
YZV	CA				YZV
YZW	CA				
YZX	CA				
ZAA	CA				
ZAC	CA				
ZAD	HR				ZAD
ZAG	HR				ZAG
ZAH	IR				
ZAJ	AF				
ZAL	CL				ZAL
ZAM	PH				
ZAO	FR				
ZAR	NG				
ZAT	CN				
ZAU	DE				
ZAW	DK				
ZAX	DE				
ZAZ	ES				
ZBD	DE				
ZBF	CA				ZBF
ZBK	ME				
ZBL	AU				
ZBM	CA				
ZBO	AU				
ZBR	IR				
ZBY	LA				
ZBZ	DE				
ZCC	DE				
ZCL	MX				ZCL
ZCO	CL				ZCO
ZDF	IL				
ZDH	CH				ZDH
ZEC	ZA				
ZEG	ID				
ZEL	CA				
ZEM	CA				
ZEN	PG				
ZER	IN				
ZFA	CA				
ZFB	CA				
ZFD	CA				
ZFL	CA				
ZFM	CA				
ZFN	CA				
ZFR	DE				
ZFW	CA				
ZGF	CA				
ZGI	CA				
ZGL	AU				
ZGM	ZM				
ZGR	CA				
ZGS	CA				
ZGU	VU				
ZHA	CN				ZHA
ZHM	BD				
ZHP	CA				
ZHZ	DE				
ZIC	CL				
ZIG	SN				
ZIH	MX				ZIH
ZIN	CH				
ZIV	GB				
ZJG	CA				
ZKB	ZM				
ZKE	CA				
ZKG	CA				
ZKL	ID				
ZKM	GA				
ZKP	ZM				
ZLG	MR				
ZLO	MX				ZLO
ZLT	CA				
ZLU	DE				
ZMD	BR				
ZMG	DE				
ZMH	CA				
ZMM	MX				
ZMT	CA				
ZNC	US				
ZND	NE				
ZNE	AU				
ZNG	CA				
ZNU	CA				
ZNV	DE				
ZNZ	TZ				ZNZ
ZOF	CA				
ZOS	CL				ZOS
ZPB	CA				
ZPC	CL				
ZPH	US				
ZPO	CA				
ZPY	DE				
ZQN	NZ				ZQN
ZQS	CA				
ZRH	CH				ZRH
ZRI	ID				
ZRJ	CA				
ZRM	ID				
ZRO	DE				
ZRR	CA				
ZRS	AT				
ZRW	DE				
ZSA	BS				
ZSE	RE				
ZSJ	CA				
ZSP	CA				
ZSS	CI				
ZST	CA				
ZSZ	CH				
ZTA	PF				
ZTB	CA				
ZTH	GR				ZTH
ZTJ	CH				
ZTM	CA				
ZTR	UA				
ZTS	CA				
ZTZ	DE				
ZUC	CA				
ZUD	CL				
ZUE	CI				
ZUH	CN				ZUH
ZUL	SA				
ZUM	CA				
ZVA	MG				
ZVG	AU				
ZVK	LA				
ZWA	MG				
ZWL	CA				
ZYI	CN				ZYI
ZYL	BD				
ZZC	US				
ZZU	MW				
ZZV	US				
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.countries (countrycode, names) FROM stdin;
AD	Andorra
AE	United Arab Emirates
AF	Afghanistan
AG	Antigua And Barbuda, Leeward Islands
AI	Anguilla, Leeward Islands
AL	Albania
AM	Armenia
AO	Angola
AQ	Antarctica
AR	Argentina
AS	American Samoa
AT	Austria
AU	Australia
AW	Aruba
AZ	Azerbaijan
BA	Bosnia And Herzegovina
BB	Barbados
BD	Bangladesh
BE	Belgium
BF	Burkina Faso
BG	Bulgaria
BH	Bahrain
BI	Burundi
BJ	Benin
BL	Saint Barthelemy
BM	Bermuda
BN	Brunei Darussalam
BO	Bolivia
BQ	Bonaire, Saint Eustatius And Saba
BR	Brazil
BS	Bahamas
BT	Bhutan
BW	Botswana
BY	Belarus
BZ	Belize
CA	Canada
CC	Cocos (Keeling) Islands
CD	Congo Democratic Republic Of
CF	Central African Republic
CG	Congo
CH	Switzerland
CI	Cote D'ivoire
CK	Cook Islands
CL	Chile
CM	Cameroon
CN	China
CO	Colombia
CR	Costa Rica
CU	Cuba
CV	Cape Verde
CW	Curacao
CX	Christmas Island, Indian Ocean
CY	Cyprus
CZ	Czech Republic
DE	Germany
DJ	Djibouti
DK	Denmark
DM	Dominica
DO	Dominican Republic
DZ	Algeria
EC	Ecuador
EE	Estonia
EG	Egypt
ER	Eritrea
ES	Spain
ET	Ethiopia
FI	Finland
FJ	Fiji
FK	Falkland Islands
FM	Micronesia Federated States Of
FO	Faroe Islands
FR	France
GA	Gabon
GB	United Kingdom
GD	Grenada, Windward Islands
GE	Georgia
GF	French Guiana
GH	Ghana
GI	Gibraltar
GL	Greenland
GM	Gambia
GN	Guinea
GP	Guadeloupe
GQ	Equatorial Guinea
GR	Greece
GT	Guatemala
GU	Guam
GW	Guinea-Bissau
GY	Guyana
HK	Hong Kong
HN	Honduras
HR	Croatia
HT	Haiti
HU	Hungary
ID	Indonesia
IE	Ireland Republic Of
IL	Israel
IN	India
IQ	Iraq
IR	Iran Islamic Republic Of
IS	Iceland
IT	Italy
JM	Jamaica
JO	Jordan
JP	Japan
KE	Kenya
KG	Kyrgyzstan
KH	Cambodia
KI	Kiribati
KM	Comoros
KN	Saint Kitts And Nevis, Leeward Island
KP	Korea Democratic People's Republic Of
KR	Korea Republic Of
KW	Kuwait
KY	Cayman Islands
KZ	Kazakhstan
LA	Lao People's Democratic Republic
LB	Lebanon
LC	Saint Lucia
LI	Liechtenstein
LK	Sri Lanka
LR	Liberia
LS	Lesotho
LT	Lithuania
LU	Luxembourg
LV	Latvia
LY	Libya
MA	Morocco
MC	Monaco
MD	Moldova Republic Of
ME	Montenegro
MF	Saint Martin
MG	Madagascar
MH	Marshall Islands
MK	North Macedonia 
ML	Mali
MM	Myanmar
MN	Mongolia
MO	Macau
MP	Northern Mariana Islands
MQ	Martinique
MR	Mauritania
MS	Montserrat, Leeward Islands
MT	Malta
MU	Mauritius
MV	Maldives
MW	Malawi
MX	Mexico
MY	Malaysia
MZ	Mozambique
NA	Namibia
NC	New Caledonia
NE	Niger
NF	Norfolk Island
NG	Nigeria
NI	Nicaragua
NL	Netherlands
NO	Norway
NP	Nepal
NR	Nauru
NU	Niue
NZ	New Zealand
OM	Oman
PA	Panama
PE	Peru
PF	French Polynesia
PG	Papua New Guinea
PH	Philippines
PK	Pakistan
PL	Poland
PM	Saint Pierre And Miquelon
PN	Pitcairn Islands
PR	Puerto Rico
PS	Palestine
PT	Portugal
PW	Palau
PY	Paraguay
QA	Qatar
RE	Reunion
RO	Romania
RS	Serbia
RU	Russian Federation
RW	Rwanda
SA	Saudi Arabia
SB	Solomon Islands
SC	Seychelles
SD	Sudan
SE	Sweden
SG	Singapore
SH	Saint Helena
SI	Slovenia
SK	Slovakia
SL	Sierra Leone
SM	San Marino
SN	Senegal
SO	Somalia
SR	Suriname
SS	South Sudan
ST	Sao Tome And Principe
SV	El Salvador
SX	St Maarten (Dutch Part)
SY	Syrian Arab Republic
SZ	Eswatini
TC	Turks And Caicos Islands
TD	Chad
TG	Togo
TH	Thailand
TJ	Tajikistan
TL	Timor-Leste
TM	Turkmenistan
TN	Tunisia
TO	Tonga
TR	Turkiye
TT	Trinidad And Tobago
TV	Tuvalu
TW	Chinese Taipei
TZ	Tanzania United Republic Of
UA	Ukraine
UG	Uganda
UM	United States Minor Outlying Islands
US	United States Of America
UY	Uruguay
UZ	Uzbekistan
VC	St Vincent And The Grenadines
VE	Venezuela
VG	Virgin Islands, British
VI	Virgin Islands, Us
VN	Viet Nam
VU	Vanuatu
WF	Wallis And Futuna Islands
WS	Samoa
XK	Kosovo Republic Of
XX	Dummy Country
YE	Yemen
YT	Mayotte
ZA	South Africa
ZM	Zambia
ZW	Zimbabwe
\.


--
-- Data for Name: experiments; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.experiments (experiment_id, name, artifact_location, lifecycle_stage, creation_time, last_update_time) FROM stdin;
0	Default	mlflow-artifacts:/0	active	1721842072710	1721842072710
\.


--
-- Data for Name: input_tags; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.input_tags (input_uuid, name, value) FROM stdin;
\.


--
-- Data for Name: inputs; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.inputs (input_uuid, source_type, source_id, destination_type, destination_id) FROM stdin;
\.


--
-- Data for Name: latest_metrics; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.latest_metrics (key, value, "timestamp", step, is_nan, run_uuid) FROM stdin;
\.


--
-- Data for Name: metrics; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.metrics (key, value, "timestamp", run_uuid, step, is_nan) FROM stdin;
\.


--
-- Data for Name: model_version_tags; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.model_version_tags (key, value, name, version) FROM stdin;
\.


--
-- Data for Name: model_versions; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.model_versions (name, version, creation_time, last_updated_time, description, user_id, current_stage, source, run_id, status, status_message, run_link, storage_location) FROM stdin;
\.


--
-- Data for Name: params; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.params (key, value, run_uuid) FROM stdin;
\.


--
-- Data for Name: registered_model_aliases; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.registered_model_aliases (alias, version, name) FROM stdin;
\.


--
-- Data for Name: registered_model_tags; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.registered_model_tags (key, value, name) FROM stdin;
\.


--
-- Data for Name: registered_models; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.registered_models (name, creation_time, last_updated_time, description) FROM stdin;
\.


--
-- Data for Name: runs; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.runs (run_uuid, name, source_type, source_name, entry_point_name, user_id, status, start_time, end_time, source_version, lifecycle_stage, artifact_uri, experiment_id, deleted_time) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.tags (key, value, run_uuid) FROM stdin;
\.


--
-- Data for Name: trace_info; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.trace_info (request_id, experiment_id, timestamp_ms, execution_time_ms, status) FROM stdin;
\.


--
-- Data for Name: trace_request_metadata; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.trace_request_metadata (key, value, request_id) FROM stdin;
\.


--
-- Data for Name: trace_tags; Type: TABLE DATA; Schema: public; Owner: airline
--

COPY public.trace_tags (key, value, request_id) FROM stdin;
\.


--
-- Name: experiments_experiment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airline
--

SELECT pg_catalog.setval('public.experiments_experiment_id_seq', 1, false);


--
-- Name: aircrafts aircrafts_pkey; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.aircrafts
    ADD CONSTRAINT aircrafts_pkey PRIMARY KEY (aircraftcode);


--
-- Name: airlines airlines_pkey; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.airlines
    ADD CONSTRAINT airlines_pkey PRIMARY KEY (airlineid);


--
-- Name: airports airports_pkey; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.airports
    ADD CONSTRAINT airports_pkey PRIMARY KEY (airportcode);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (citycode);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (countrycode);


--
-- Name: experiments experiment_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.experiments
    ADD CONSTRAINT experiment_pk PRIMARY KEY (experiment_id);


--
-- Name: experiments experiments_name_key; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.experiments
    ADD CONSTRAINT experiments_name_key UNIQUE (name);


--
-- Name: input_tags input_tags_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.input_tags
    ADD CONSTRAINT input_tags_pk PRIMARY KEY (input_uuid, name);


--
-- Name: inputs inputs_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.inputs
    ADD CONSTRAINT inputs_pk PRIMARY KEY (source_type, source_id, destination_type, destination_id);


--
-- Name: latest_metrics latest_metric_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.latest_metrics
    ADD CONSTRAINT latest_metric_pk PRIMARY KEY (key, run_uuid);


--
-- Name: metrics metric_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.metrics
    ADD CONSTRAINT metric_pk PRIMARY KEY (key, "timestamp", step, run_uuid, value, is_nan);


--
-- Name: model_versions model_version_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.model_versions
    ADD CONSTRAINT model_version_pk PRIMARY KEY (name, version);


--
-- Name: model_version_tags model_version_tag_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.model_version_tags
    ADD CONSTRAINT model_version_tag_pk PRIMARY KEY (key, name, version);


--
-- Name: params param_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.params
    ADD CONSTRAINT param_pk PRIMARY KEY (key, run_uuid);


--
-- Name: registered_model_aliases registered_model_alias_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.registered_model_aliases
    ADD CONSTRAINT registered_model_alias_pk PRIMARY KEY (name, alias);


--
-- Name: registered_models registered_model_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.registered_models
    ADD CONSTRAINT registered_model_pk PRIMARY KEY (name);


--
-- Name: registered_model_tags registered_model_tag_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.registered_model_tags
    ADD CONSTRAINT registered_model_tag_pk PRIMARY KEY (key, name);


--
-- Name: runs run_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT run_pk PRIMARY KEY (run_uuid);


--
-- Name: tags tag_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tag_pk PRIMARY KEY (key, run_uuid);


--
-- Name: trace_info trace_info_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.trace_info
    ADD CONSTRAINT trace_info_pk PRIMARY KEY (request_id);


--
-- Name: trace_request_metadata trace_request_metadata_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.trace_request_metadata
    ADD CONSTRAINT trace_request_metadata_pk PRIMARY KEY (key, request_id);


--
-- Name: trace_tags trace_tag_pk; Type: CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.trace_tags
    ADD CONSTRAINT trace_tag_pk PRIMARY KEY (key, request_id);


--
-- Name: index_inputs_destination_type_destination_id_source_type; Type: INDEX; Schema: public; Owner: airline
--

CREATE INDEX index_inputs_destination_type_destination_id_source_type ON public.inputs USING btree (destination_type, destination_id, source_type);


--
-- Name: index_inputs_input_uuid; Type: INDEX; Schema: public; Owner: airline
--

CREATE INDEX index_inputs_input_uuid ON public.inputs USING btree (input_uuid);


--
-- Name: index_latest_metrics_run_uuid; Type: INDEX; Schema: public; Owner: airline
--

CREATE INDEX index_latest_metrics_run_uuid ON public.latest_metrics USING btree (run_uuid);


--
-- Name: index_metrics_run_uuid; Type: INDEX; Schema: public; Owner: airline
--

CREATE INDEX index_metrics_run_uuid ON public.metrics USING btree (run_uuid);


--
-- Name: index_params_run_uuid; Type: INDEX; Schema: public; Owner: airline
--

CREATE INDEX index_params_run_uuid ON public.params USING btree (run_uuid);


--
-- Name: index_tags_run_uuid; Type: INDEX; Schema: public; Owner: airline
--

CREATE INDEX index_tags_run_uuid ON public.tags USING btree (run_uuid);


--
-- Name: index_trace_info_experiment_id_timestamp_ms; Type: INDEX; Schema: public; Owner: airline
--

CREATE INDEX index_trace_info_experiment_id_timestamp_ms ON public.trace_info USING btree (experiment_id, timestamp_ms);


--
-- Name: index_trace_request_metadata_request_id; Type: INDEX; Schema: public; Owner: airline
--

CREATE INDEX index_trace_request_metadata_request_id ON public.trace_request_metadata USING btree (request_id);


--
-- Name: index_trace_tags_request_id; Type: INDEX; Schema: public; Owner: airline
--

CREATE INDEX index_trace_tags_request_id ON public.trace_tags USING btree (request_id);


--
-- Name: trace_info fk_trace_info_experiment_id; Type: FK CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.trace_info
    ADD CONSTRAINT fk_trace_info_experiment_id FOREIGN KEY (experiment_id) REFERENCES public.experiments(experiment_id);


--
-- Name: trace_request_metadata fk_trace_request_metadata_request_id; Type: FK CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.trace_request_metadata
    ADD CONSTRAINT fk_trace_request_metadata_request_id FOREIGN KEY (request_id) REFERENCES public.trace_info(request_id) ON DELETE CASCADE;


--
-- Name: trace_tags fk_trace_tags_request_id; Type: FK CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.trace_tags
    ADD CONSTRAINT fk_trace_tags_request_id FOREIGN KEY (request_id) REFERENCES public.trace_info(request_id) ON DELETE CASCADE;


--
-- Name: latest_metrics latest_metrics_run_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.latest_metrics
    ADD CONSTRAINT latest_metrics_run_uuid_fkey FOREIGN KEY (run_uuid) REFERENCES public.runs(run_uuid);


--
-- Name: metrics metrics_run_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.metrics
    ADD CONSTRAINT metrics_run_uuid_fkey FOREIGN KEY (run_uuid) REFERENCES public.runs(run_uuid);


--
-- Name: model_version_tags model_version_tags_name_version_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.model_version_tags
    ADD CONSTRAINT model_version_tags_name_version_fkey FOREIGN KEY (name, version) REFERENCES public.model_versions(name, version) ON UPDATE CASCADE;


--
-- Name: model_versions model_versions_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.model_versions
    ADD CONSTRAINT model_versions_name_fkey FOREIGN KEY (name) REFERENCES public.registered_models(name) ON UPDATE CASCADE;


--
-- Name: params params_run_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.params
    ADD CONSTRAINT params_run_uuid_fkey FOREIGN KEY (run_uuid) REFERENCES public.runs(run_uuid);


--
-- Name: registered_model_aliases registered_model_alias_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.registered_model_aliases
    ADD CONSTRAINT registered_model_alias_name_fkey FOREIGN KEY (name) REFERENCES public.registered_models(name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registered_model_tags registered_model_tags_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.registered_model_tags
    ADD CONSTRAINT registered_model_tags_name_fkey FOREIGN KEY (name) REFERENCES public.registered_models(name) ON UPDATE CASCADE;


--
-- Name: runs runs_experiment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT runs_experiment_id_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiments(experiment_id);


--
-- Name: tags tags_run_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airline
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_run_uuid_fkey FOREIGN KEY (run_uuid) REFERENCES public.runs(run_uuid);


--
-- PostgreSQL database dump complete
--

