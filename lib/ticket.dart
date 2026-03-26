class Ticket {
  Pagination? pagination;
  List<Data>? data;

  Ticket({this.pagination, this.data});

  Ticket.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Pagination {
  int? limit;
  int? offset;
  int? count;
  int? total;

  Pagination({this.limit, this.offset, this.count, this.total});

  Pagination.fromJson(Map<String, dynamic> json) {
    limit = json['limit'];
    offset = json['offset'];
    count = json['count'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['limit'] = this.limit;
    data['offset'] = this.offset;
    data['count'] = this.count;
    data['total'] = this.total;
    return data;
  }
}

class Data {
  String? flightDate;
  String? flightStatus;
  Departure? departure;
  Arrival? arrival;
  Airline? airline;
  Flight? flight;
  dynamic aircraft;
  dynamic live;

  Data(
      {this.flightDate,
      this.flightStatus,
      this.departure,
      this.arrival,
      this.airline,
      this.flight,
      this.aircraft,
      this.live});

  Data.fromJson(Map<String, dynamic> json) {
    flightDate = json['flight_date'];
    flightStatus = json['flight_status'];
    departure = json['departure'] != null
        ? new Departure.fromJson(json['departure'])
        : null;
    arrival =
        json['arrival'] != null ? new Arrival.fromJson(json['arrival']) : null;
    airline =
        json['airline'] != null ? new Airline.fromJson(json['airline']) : null;
    flight =
        json['flight'] != null ? new Flight.fromJson(json['flight']) : null;
    aircraft = json['aircraft'];
    live = json['live'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['flight_date'] = this.flightDate;
    data['flight_status'] = this.flightStatus;
    if (this.departure != null) {
      data['departure'] = this.departure!.toJson();
    }
    if (this.arrival != null) {
      data['arrival'] = this.arrival!.toJson();
    }
    if (this.airline != null) {
      data['airline'] = this.airline!.toJson();
    }
    if (this.flight != null) {
      data['flight'] = this.flight!.toJson();
    }
    data['aircraft'] = this.aircraft;
    data['live'] = this.live;
    return data;
  }
}

class Departure {
  String? airport;
  String? timezone;
  String? iata;
  String? icao;
  String? terminal;
  String? gate;
  int? delay;
  String? scheduled;
  String? estimated;
  String? actual;
  String? estimatedRunway;
  String? actualRunway;

  Departure(
      {this.airport,
      this.timezone,
      this.iata,
      this.icao,
      this.terminal,
      this.gate,
      this.delay,
      this.scheduled,
      this.estimated,
      this.actual,
      this.estimatedRunway,
      this.actualRunway});

  Departure.fromJson(Map<String, dynamic> json) {
    airport = json['airport'];
    timezone = json['timezone'];
    iata = json['iata'];
    icao = json['icao'];
    terminal = json['terminal'];
    gate = json['gate'];
    delay = json['delay'];
    scheduled = json['scheduled'];
    estimated = json['estimated'];
    actual = json['actual'];
    estimatedRunway = json['estimated_runway'];
    actualRunway = json['actual_runway'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['airport'] = this.airport;
    data['timezone'] = this.timezone;
    data['iata'] = this.iata;
    data['icao'] = this.icao;
    data['terminal'] = this.terminal;
    data['gate'] = this.gate;
    data['delay'] = this.delay;
    data['scheduled'] = this.scheduled;
    data['estimated'] = this.estimated;
    data['actual'] = this.actual;
    data['estimated_runway'] = this.estimatedRunway;
    data['actual_runway'] = this.actualRunway;
    return data;
  }
}

class Arrival {
  String? airport;
  String? timezone;
  String? iata;
  String? icao;
  String? terminal;
  String? gate;
  String? baggage;
  String? scheduled;
  int? delay;
  String? estimated;
  String? actual;
  String? estimatedRunway;
  String? actualRunway;

  Arrival(
      {this.airport,
      this.timezone,
      this.iata,
      this.icao,
      this.terminal,
      this.gate,
      this.baggage,
      this.scheduled,
      this.delay,
      this.estimated,
      this.actual,
      this.estimatedRunway,
      this.actualRunway});

  Arrival.fromJson(Map<String, dynamic> json) {
    airport = json['airport'];
    timezone = json['timezone'];
    iata = json['iata'];
    icao = json['icao'];
    terminal = json['terminal'];
    gate = json['gate'];
    baggage = json['baggage'];
    scheduled = json['scheduled'];
    delay = json['delay'];
    estimated = json['estimated'];
    actual = json['actual'];
    estimatedRunway = json['estimated_runway'];
    actualRunway = json['actual_runway'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['airport'] = this.airport;
    data['timezone'] = this.timezone;
    data['iata'] = this.iata;
    data['icao'] = this.icao;
    data['terminal'] = this.terminal;
    data['gate'] = this.gate;
    data['baggage'] = this.baggage;
    data['scheduled'] = this.scheduled;
    data['delay'] = this.delay;
    data['estimated'] = this.estimated;
    data['actual'] = this.actual;
    data['estimated_runway'] = this.estimatedRunway;
    data['actual_runway'] = this.actualRunway;
    return data;
  }
}

class Airline {
  String? name;
  String? iata;
  String? icao;

  Airline({this.name, this.iata, this.icao});

  Airline.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    iata = json['iata'];
    icao = json['icao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['iata'] = this.iata;
    data['icao'] = this.icao;
    return data;
  }
}

class Flight {
  String? number;
  String? iata;
  String? icao;
  Codeshared? codeshared;

  Flight({this.number, this.iata, this.icao, this.codeshared});

  Flight.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    iata = json['iata'];
    icao = json['icao'];
    codeshared = json['codeshared'] != null
        ? new Codeshared.fromJson(json['codeshared'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['number'] = this.number;
    data['iata'] = this.iata;
    data['icao'] = this.icao;
    if (this.codeshared != null) {
      data['codeshared'] = this.codeshared!.toJson();
    }
    return data;
  }
}

class Codeshared {
  String? airlineName;
  String? airlineIata;
  String? airlineIcao;
  String? flightNumber;
  String? flightIata;
  String? flightIcao;

  Codeshared(
      {this.airlineName,
      this.airlineIata,
      this.airlineIcao,
      this.flightNumber,
      this.flightIata,
      this.flightIcao});

  Codeshared.fromJson(Map<String, dynamic> json) {
    airlineName = json['airline_name'];
    airlineIata = json['airline_iata'];
    airlineIcao = json['airline_icao'];
    flightNumber = json['flight_number'];
    flightIata = json['flight_iata'];
    flightIcao = json['flight_icao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['airline_name'] = this.airlineName;
    data['airline_iata'] = this.airlineIata;
    data['airline_icao'] = this.airlineIcao;
    data['flight_number'] = this.flightNumber;
    data['flight_iata'] = this.flightIata;
    data['flight_icao'] = this.flightIcao;
    return data;
  }
}