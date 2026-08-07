CREATE TABLE inbound (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_code TEXT NOT NULL,
    shop_name TEXT,
	brand_name TEXT,
    region TEXT,
    box_qty INTEGER DEFAULT 0 CHECK (box_qty >= 0),
    input_standard INTEGER DEFAULT 0 CHECK (input_standard >= 0),
    input_taras_defect INTEGER DEFAULT 0 CHECK (input_taras_defect >= 0),
    input_paper_bag INTEGER DEFAULT 0 CHECK (input_paper_bag >= 0),
    input_visual_merchandising INTEGER DEFAULT 0 CHECK (input_visual_merchandising >= 0),
    input_type TEXT DEFAULT '-',
    status TEXT DEFAULT 'Pending',
    purchase_order_num TEXT DEFAULT '-',
    delivery_order_num TEXT DEFAULT '-',
	good_issue_date TEXT CHECK ( good_issue_date IS NULL OR (good_issue_date GLOB '[1-2][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]' AND strftime('%Y-%m-%d', good_issue_date) = good_issue_date)),
    transfer_order_num TEXT DEFAULT '-',
    put_away_bin TEXT DEFAULT '-',
    transfer_order_quality_issue TEXT DEFAULT '-',
    substandard_qty INTEGER DEFAULT 0 CHECK (substandard_qty >= 0),   
    arrival_date TEXT CHECK ( arrival_date IS NULL OR (arrival_date GLOB '[1-2][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]' AND strftime('%Y-%m-%d', arrival_date) = arrival_date)),
    current_action TEXT CHECK (current_action IN ('post', 'confirm') OR current_action IS NULL),
    good_receipt_date TEXT CHECK ( good_receipt_date IS NULL OR (good_receipt_date GLOB '[1-2][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]' AND strftime('%Y-%m-%d', good_receipt_date) = good_receipt_date)),
    note TEXT DEFAULT '-',
    inbound_code TEXT,
    way_bill TEXT DEFAULT '-',
    checklist TEXT DEFAULT 0,
    FOREIGN KEY (shop_code) REFERENCES shop(shop_code)
        ON UPDATE CASCADE,
    FOREIGN KEY (good_issue_date) REFERENCES date_tb(Date),
    FOREIGN KEY (arrival_date) REFERENCES date_tb(Date),
    FOREIGN KEY (good_receipt_date) REFERENCES date_tb(Date)
);

CREATE TABLE outbound (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    post_date DATE CHECK (post_date IS NULL OR strftime('%Y-%m-%d', post_date) = post_date),
    order_date DATE DEFAULT (DATE('now')) CHECK (strftime('%Y-%m-%d', order_date) = order_date),
    delivery_date DATE DEFAULT (DATE('now')) CHECK (strftime('%Y-%m-%d', delivery_date) = delivery_date),
    main_vendor TEXT DEFAULT 'D111',
    brand_name TEXT,
    region TEXT,
    shop_code TEXT NOT NULL,
    shop_name TEXT,
    product_qty INTEGER DEFAULT 0 CHECK (product_qty >= 0),
    paper_bag_qty INTEGER DEFAULT 0 CHECK (paper_bag_qty >= 0),
    stock_transfer_order_num TEXT DEFAULT '-',
    delivery_order_num TEXT DEFAULT '-',
    note TEXT DEFAULT '-',
    box_qty INTEGER DEFAULT 0 CHECK (box_qty >= 0),
    order_qty INTEGER DEFAULT 0 CHECK (order_qty >= 0),
    transfer_order_num TEXT DEFAULT '-',
    passed_qc_qty INTEGER DEFAULT 0,
    failed_qc_qty INTEGER DEFAULT 0,
    note2 TEXT DEFAULT '-',
    checklist TEXT DEFAULT 0,
    FOREIGN KEY (shop_code) REFERENCES shop(shop_code)
        --ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (post_date) REFERENCES date_tb(Date),
    FOREIGN KEY (order_date) REFERENCES date_tb(Date),
    FOREIGN KEY (delivery_date) REFERENCES date_tb(Date)
);

CREATE TABLE a_diary (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    diary_date DATE DEFAULT (DATE('now')) CHECK (strftime('%Y-%m-%d', diary_date) = diary_date),
    content TEXT DEFAULT '-',
    box INTEGER DEFAULT 0 CHECK (box >= 0),
    qty INTEGER DEFAULT 0 CHECK (qty >= 0),
    shop TEXT DEFAULT '-',
    location TEXT DEFAULT '-',
    note TEXT DEFAULT '-',
    status TEXT DEFAULT '-'
);

CREATE TABLE shop (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_code TEXT UNIQUE NOT NULL,
    brand TEXT NOT NULL DEFAULT '-',
    shop_name TEXT DEFAULT '-',
    status TEXT DEFAULT '-',
    carrier TEXT DEFAULT '-',
   	shop_type TEXT DEFAULT '-',
    pickup_time TEXT CHECK (pickup_time GLOB '[0-2][0-9]:[0-5][0-9]' AND CAST(substr(pickup_time, 1, 2) AS INTEGER) <= 23 ) DEFAULT '00:00',
    delivery_time TEXT CHECK (delivery_time GLOB '[0-2][0-9]:[0-5][0-9]' AND CAST(substr(delivery_time, 1, 2) AS INTEGER) <= 23 ) DEFAULT '00:00',
    lead_time_day INTEGER DEFAULT 0,
    mail_address TEXT DEFAULT '-',
    shop_address TEXT DEFAULT '-',
    phone_number TEXT DEFAULT '-',
    latitude TEXT DEFAULT 0,
    longitude TEXT DEFAULT 0,
    province_id INTEGER DEFAULT 44 NOT NULL CHECK (province_id >= 0),
    note TEXT DEFAULT '-',
    checklist TEXT DEFAULT 0,
    FOREIGN KEY (brand) REFERENCES brand(brand_code)
        ON UPDATE CASCADE,
    FOREIGN KEY (province_id) REFERENCES province(id)
        ON UPDATE CASCADE,
    FOREIGN KEY (carrier) REFERENCES carrier(id)
);

CREATE TABLE carrier (
    id TEXT PRIMARY KEY,
    name TEXT DEFAULT '-',
    tracking_url TEXT DEFAULT '-',
    contact_name TEXT DEFAULT '-',
    contact_phone TEXT DEFAULT '-'
);

CREATE TABLE carrier_service (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    carrier_id TEXT,
    transport_mode TEXT,
    FOREIGN KEY (carrier_id) REFERENCES carrier(id)
);

CREATE TABLE pullback (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pullback_date DATE NOT NULL CHECK (strftime('%Y-%m-%d', pullback_date) = pullback_date),
    from_shop TEXT NOT NULL,
    to_shop TEXT NOT NULL,
    box_qty INTEGER DEFAULT 0 CHECK (box_qty >= 0),
    product INTEGER DEFAULT 0 CHECK (product >= 0),
    paper_bag INTEGER DEFAULT 0 CHECK (paper_bag >= 0),
    note TEXT DEFAULT '-',
    FOREIGN KEY (from_shop) REFERENCES shop(shop_code)
        ON UPDATE CASCADE,
    FOREIGN KEY (to_shop) REFERENCES shop(shop_code)
        ON UPDATE CASCADE,
    FOREIGN KEY (pullback_date) REFERENCES date_tb(Date)
);

CREATE TABLE defect (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    results TEXT,
    purchase_order_num TEXT NOT NULL,
    shop_name TEXT,
    defect_qty INTEGER CHECK (defect_qty >= 0),
    barcode TEXT,
    artical TEXT,
    item_full_name TEXT,
    defect_type TEXT DEFAULT '-',
    solution TEXT DEFAULT '-',
    note TEXT DEFAULT '-',
    style_code TEXT,
    checklist TEXT DEFAULT '-',
    FOREIGN KEY (purchase_order_num) REFERENCES inbound(purchase_order_num)
        --ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (barcode) REFERENCES item_list(barcode)
        ON UPDATE CASCADE
    FOREIGN KEY (artical) REFERENCES item_list(variant)
        ON UPDATE CASCADE
);

CREATE TABLE defect_type (
id INTEGER PRIMARY KEY AUTOINCREMENT,
classification TEXT,
vn_description TEXT
);

CREATE TABLE province (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	region TEXT NOT NULL,
	province_name TEXT UNIQUE NOT NULL,
	area TEXT NOT NULL
);

CREATE TABLE item_list (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    brand_name TEXT NOT NULL,
    style_code TEXT DEFAULT '-',
    variant TEXT NOT NULL,
    unit TEXT DEFAULT '-',
    barcode TEXT UNIQUE NOT NULL,
    color TEXT DEFAULT '-',
    sizes TEXT DEFAULT '-',
    full_price INTEGER CHECK (full_price >= 0),
    markdown_price INTEGER CHECK (markdown_price >= 0),
    type TEXT,
    item_full_name TEXT,
    FOREIGN KEY (brand_name) REFERENCES brand(brand_name)
        --ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (type) REFERENCES item_type(type)
        --ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE item_type (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	type TEXT
);

CREATE TABLE carrier_area (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    carier TEXT,
	area_code TEXT,
	province TEXT,
	FOREIGN KEY (carier) REFERENCES carrier(id)
);

CREATE TABLE carrier_zone_hcm (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    carier TEXT,
	zone_id TEXT,
	description TEXT,
	FOREIGN KEY (carier) REFERENCES carrier(id)
);

CREATE TABLE carrier_vehicle (
    id TEXT UNIQUE,
    name TEXT
);

CREATE TABLE carrier_zone_hcm_pricing (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    carrier TEXT,
    zone_id TEXT,
    vehicle_type TEXT,
    base_price INTEGER,
    extra_same_area INTEGER,
    extra_other_area INTEGER,
    loading_fee INTEGER,
    FOREIGN KEY (carrier) REFERENCES carrier(id) ON UPDATE CASCADE,
    FOREIGN KEY (zone_id) REFERENCES carrier_zone_hcm(zone_id) ON UPDATE CASCADE,
    FOREIGN KEY (vehicle_type) REFERENCES carrier_vehicle(id) ON UPDATE CASCADE
);

CREATE TABLE carrier_price (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    carrier TEXT,
    area TEXT,
   	tranport_type TEXT,
	weight_step_kg TEXT,
	price INTEGER DEFAULT 0,
	FOREIGN KEY (carrier) REFERENCES carrier(id)
);

CREATE TABLE carrier_lead_time (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    carrier TEXT,
    tranport_type TEXT NOT NULL,
	area TEXT NOT NULL,
	lead_time TEXT NOT NULL,
    FOREIGN KEY (carrier) REFERENCES carrier(id)
);

CREATE TABLE date_tb (
    date_id INTEGER PRIMARY KEY AUTOINCREMENT,
    Date DATE NOT NULL UNIQUE,
    Day_Of_Month INTEGER NOT NULL CHECK (Day_Of_Month BETWEEN 1 AND 31),
    Month_Number_Of_Year INTEGER NOT NULL CHECK (Month_Number_Of_Year BETWEEN 1 AND 12),
    Year INTEGER NOT NULL,
    Day_Of_Week_Number INTEGER NOT NULL CHECK (Day_Of_Week_Number BETWEEN 1 AND 7),
    Month_Name TEXT NOT NULL,
    Day_Name TEXT NOT NULL,
    Start_of_Week DATE NOT NULL,
    Start_of_Month DATE NOT NULL,
    Start_of_Quarter DATE NOT NULL,
    Start_of_Year DATE NOT NULL,
    Quarter INTEGER,
    Weekend TEXT,
    Month_Short TEXT
);

CREATE TABLE brand (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    brand_code TEXT UNIQUE NOT NULL,
    brand_name TEXT NOT NULL,
    storage_location TEXT NOT NULL
);

CREATE TABLE item_material (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
    barcode TEXT,
    material TEXT DEFAULT '-',
    FOREIGN KEY (barcode) REFERENCES item_list(barcode)
);

CREATE TABLE cyclecount (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site TEXT NOT NULL,
    storage_type TEXT,
	brand_code TEXT,
	brand_name TEXT,
    cyclecount_num TEXT,	
    cyclecount_qty INTEGER DEFAULT 0,
    scan_qty INTEGER DEFAULT 0,
    different INTEGER DEFAULT 0,
    document_date DATE DEFAULT (DATE('now')),
    status TEXT DEFAULT 'process',
    results TEXT  DEFAULT '-',
    location TEXT  DEFAULT '-',
    note TEXT DEFAULT '-',
    FOREIGN KEY (brand_code) REFERENCES brand(brand_code)
        --ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (document_date) REFERENCES date_tb(Date)
);

CREATE TABLE stocktaking (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site TEXT NOT NULL,
    storage_type TEXT,
	brand_code TEXT,
	brand_name TEXT,
    stocktaking_num TEXT,	
    stocktaking_qty INTEGER DEFAULT 0,
    scan_qty INTEGER DEFAULT 0,
    different INTEGER DEFAULT 0,
    document_date DATE CHECK (document_date IS NULL OR strftime('%Y-%m-%d', document_date) = document_date),
    status TEXT DEFAULT 'process',
    results TEXT  DEFAULT '-',
    location TEXT  DEFAULT '-',
    note TEXT DEFAULT '-',
    FOREIGN KEY (brand_code) REFERENCES brand(brand_code)
        --ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (document_date) REFERENCES date_tb(Date)
);

CREATE TABLE a_bin_temp (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bin TEXT NOT NULL,
    section TEXT,
	note TEXT,
	qty INTEGER,
    note2 TEXT DEFAULT '-'
);

CREATE TABLE item_paper_bag (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    brand_name TEXT,
    style_code TEXT,
    variant TEXT,
    barcode TEXT NOT NULL,
    color TEXT DEFAULT '-',
    size TEXT DEFAULT '-',
    qty_per_box INTEGER DEFAULT 0,
    FOREIGN KEY (barcode) REFERENCES item_list(barcode)
        ON UPDATE CASCADE
);

CREATE TABLE item_ecom_bag (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    barcode TEXT NOT NULL,
    artical TEXT,
    description TEXT DEFAULT '-',
    en_name TEXT DEFAULT '-',
    vn_name TEXT DEFAULT '-',
    size TEXT DEFAULT '-',
    length TEXT DEFAULT '-',
    width TEXT DEFAULT '-',
    height TEXT DEFAULT '-',
    price TEXT DEFAULT '-',
    info TEXT DEFAULT '-',
    note TEXT DEFAULT '-',
    FOREIGN KEY (barcode) REFERENCES item_list(barcode)
        ON UPDATE CASCADE
);

CREATE TABLE outbound_groupx (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_code TEXT NOT NULL,
    brand TEXT,
    shop_name TEXT,
	groupx TEXT,
    FOREIGN KEY (shop_code) REFERENCES shop(shop_code)
);

CREATE TABLE outbound_include (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    dely_date DATE DEFAULT (DATE('now')),
    shop_code TEXT,
    shop_name TEXT,
    box_qty INTEGER DEFAULT 0,
    item_name TEXT DEFAULT '-',
    note TEXT DEFAULT '-',
    FOREIGN KEY (shop_code) REFERENCES shop(shop_code)
        ON UPDATE CASCADE,
    FOREIGN KEY (dely_date) REFERENCES date_tb(Date)
);

CREATE TABLE inbound_visual_asset (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    item_name TEXT DEFAULT '-',
    qty_box INTEGER DEFAULT 0,
    quantity INTEGER DEFAULT 0,
    status TEXT CHECK (status IN ('inbound', 'outbound')),
    note TEXT DEFAULT '-',
    check_date DATE DEFAULT (DATE('now')) CHECK (strftime('%Y-%m-%d', check_date) = check_date),
    FOREIGN KEY (check_date) REFERENCES date_tb(Date)
);

CREATE TABLE employee (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_code TEXT UNIQUE,
    employee_full_name TEXT DEFAULT '-',
    employee_short_name TEXT DEFAULT '-',
    user_SAP TEXT UNIQUE,
    gender TEXT CHECK (gender IN ('Male', 'Female', 'Other')) DEFAULT 'Male',
    phone_number TEXT DEFAULT '-',
    employee_role TEXT DEFAULT '-',
    is_direct_labor BOOLEAN DEFAULT TRUE,
    start_date DATE CHECK (start_date IS NULL OR strftime('%Y-%m-%d', start_date) = start_date),
    end_date DATE CHECK (end_date IS NULL OR strftime('%Y-%m-%d', end_date) = end_date),
    main_site_code TEXT DEFAULT 'D111',
    note TEXT DEFAULT '-',
    FOREIGN KEY (start_date) REFERENCES date_tb(Date),
    FOREIGN KEY (end_date) REFERENCES date_tb(Date)
);

CREATE TABLE outbound_disparity (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    disparity_date DATE DEFAULT (DATE('now'))
        CHECK (disparity_date IS NULL OR strftime('%Y-%m-%d', disparity_date) = disparity_date),
    user_SAP TEXT DEFAULT '-',
    employee_short_name TEXT DEFAULT '-',
    delivery_order_num TEXT,
    barcode TEXT NOT NULL,
    item_full_name TEXT DEFAULT '-',
    TO_num INTEGER DEFAULT 0,
    pick_num INTEGER DEFAULT 0,
    pack_num INTEGER DEFAULT 0,
    note TEXT DEFAULT '-',
    FOREIGN KEY (barcode) REFERENCES item_list(barcode),
    FOREIGN KEY (user_SAP) REFERENCES employee(user_SAP),
    FOREIGN KEY (disparity_date) REFERENCES date_tb(Date),
    FOREIGN KEY (delivery_order_num) REFERENCES outbound(delivery_order_num)
);

CREATE TABLE inbound_ecom (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    barcode TEXT NOT NULL,
    qty INTEGER CHECK (qty >= 0),
    artical TEXT,
    purchase_order_num TEXT,
    en_name TEXT DEFAULT '-',
    vn_name TEXT DEFAULT '-',
    note TEXT DEFAULT '-',
    FOREIGN KEY (barcode) REFERENCES item_list(barcode)
    ON UPDATE CASCADE,
    FOREIGN KEY (purchase_order_num) REFERENCES inbound(purchase_order_num)
    ON UPDATE CASCADE
);

CREATE TABLE a_documentation (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT,
    name TEXT,
	description TEXT
);

CREATE TABLE type_of_defect (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    classification TEXT,
    description TEXT
);

CREATE TABLE cyclecount (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site TEXT NOT NULL,
    storage_type TEXT,
	brand_code TEXT,
	brand_name TEXT,
    cyclecount_num TEXT,	
    cyclecount_qty INTEGER DEFAULT 0,
    scan_qty INTEGER DEFAULT 0,
    different INTEGER DEFAULT 0,
    document_date DATE DEFAULT (DATE('now')),
    status TEXT DEFAULT 'process',
    results TEXT  DEFAULT '-',
    location TEXT  DEFAULT '-',
    note TEXT DEFAULT '-',
    FOREIGN KEY (brand_code) REFERENCES brand(brand_code)
        --ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (document_date) REFERENCES date_tb(Date)
);

CREATE TABLE cyclecountdata (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	cyclecount_num text,
	barcode text,
	location text,
	stock_qty integer,
	cyclecount_qty integer,
	disparity integer,
	FOREIGN KEY (barcode) REFERENCES item(Barcode)
	FOREIGN KEY (cyclecount_num) REFERENCES cyclecount(cyclecount_num)
	ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE userhistory (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_pda TEXT,
    employee_code text,
    start_date DATE CHECK ( start_date IS NULL OR strftime('%Y-%m-%d', start_date) = start_date ),
    end_date DATE CHECK ( end_date IS NULL OR strftime('%Y-%m-%d', end_date) = end_date ),
    FOREIGN KEY (employee_code) REFERENCES employee(employee_code)
    FOREIGN KEY (start_date) REFERENCES datetb(Date)
    FOREIGN KEY (end_date) REFERENCES datetb(Date)
--    id, user_pda, employee_code, start_date, end_date
);

CREATE TABLE typedata (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	type_scan text unique not null,
	type_scan_full_name text
);

CREATE TABLE datascan (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	type_scan text not null,
	username text not null,
	barcode text not null,
	scan_qty integer not null,
	scan_date date CHECK ( scan_date IS NULL OR strftime('%Y-%m-%d', scan_date) = scan_date ),
	FOREIGN KEY (barcode) REFERENCES item(barcode)
	FOREIGN KEY (type_scan) REFERENCES typedata(type_scan)
	FOREIGN KEY (username) REFERENCES userhistory(user_pda)
	FOREIGN KEY (scan_date) REFERENCES datetb(Date)
	ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE inbound_cont(
  id INT,
  shop_code TEXT,
  shop_name TEXT,
  brand_name TEXT,
  region TEXT,
  box_qty INT,
  input_standard INT,
  input_taras_defect INT,
  input_paper_bag INT,
  input_visual_merchandising INT,
  input_type TEXT,
  status TEXT,
  purchase_order_num TEXT,
  delivery_order_num TEXT,
  good_issue_date DATE,
  transfer_order_num TEXT,
  put_away_bin TEXT,
  transfer_order_quality_issue TEXT,
  substandard_qty INT,
  arrival_date DATE ,
  current_action TEXT,
  good_receipt_date DATE,
  note TEXT,
  inbound_code TEXT,
  way_bill TEXT,
  checklist TEXT
);

CREATE TABLE inbound_pullback(
  id INT,
  shop_code TEXT,
  shop_name TEXT,
  brand_name TEXT,
  region TEXT,
  box_qty INT,
  input_standard INT,
  input_taras_defect INT,
  input_paper_bag INT,
  input_visual_merchandising INT,
  input_type TEXT,
  status TEXT,
  purchase_order_num TEXT,
  delivery_order_num TEXT,
  good_issue_date DATE,
  transfer_order_num TEXT,
  put_away_bin TEXT,
  transfer_order_quality_issue TEXT,
  substandard_qty INT,
  arrival_date DATE,
  current_action TEXT,
  good_receipt_date DATE,
  note TEXT,
  inbound_code TEXT,
  way_bill TEXT,
  checklist TEXT
);

CREATE TABLE task_type (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	type TEXT,
	standard_rate INTEGER DEFAULT 0 CHECK (standard_rate >= 0)
);

CREATE TABLE fact_work_output (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id TEXT UNIQUE DEFAULT (
    'TASK_' || strftime('%Y%m%d%H%M%S', 'now', 'localtime') 
    || '_' || abs(random() % 10000)
),
    document TEXT DEFAULT '-',
    note TEXT DEFAULT '-',
    start_time TEXT CHECK (start_time GLOB '[0-2][0-9]:[0-5][0-9]' AND CAST(substr(start_time, 1, 2) AS INTEGER) <= 23 ),
    end_time TEXT CHECK (end_time GLOB '[0-2][0-9]:[0-5][0-9]' AND CAST(substr(end_time, 1, 2) AS INTEGER) <= 23 ),
	date DATE DEFAULT (DATE('now')),
    task_type TEXT DEFAULT '-',
    employee_id_involve TEXT DEFAULT '-',
    work_output INTEGER DEFAULT 0 CHECK (work_output >= 0),    
    FOREIGN KEY (date) REFERENCES date_tb(Date)
    FOREIGN KEY (task_type) REFERENCES task_type(type)
);

CREATE TABLE soh (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date DATE NOT NULL CHECK (strftime('%Y-%m-%d', date) = date),
    site TEXT NOT NULL CHECK (site IN ('D111', 'D116')),
    barcode TEXT NOT NULL,
    qty INTEGER NOT NULL CHECK (qty >= 0),
    FOREIGN KEY (date) REFERENCES date_tb(Date),
    FOREIGN KEY (barcode) REFERENCES item_list(barcode)
);

CREATE TABLE a_tcode (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT DEFAULT '-',
    t_code TEXT UNIQUE,
	description TEXT DEFAULT '-'
);

CREATE TABLE a_reminder (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    note TEXT NOT NULL,
    created_at DATE DEFAULT (DATE('now')) CHECK (strftime('%Y-%m-%d', created_at) = created_at)
);