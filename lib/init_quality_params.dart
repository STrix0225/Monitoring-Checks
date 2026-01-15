import 'package:monitoringng1/restapi.dart';
import 'dart:convert';

class QualityParamsInitializer {
  static final DataService _ds = DataServiceV2();
  
  static Future<void> initializeAllParameters() async {
    print('🔄 Initializing quality parameters...');
    
    try {
      // BODY PARTS
      await _initializeBodyParts();
      
      // FUEL SYSTEM PARTS
      await _initializeFuelSystemParts();
      
      // EXHAUST SYSTEM PARTS
      await _initializeExhaustSystemParts();
      
      // SUSPENSION PARTS
      await _initializeSuspensionParts();
      
      // INTERIOR PARTS
      await _initializeInteriorParts();
      
      print('✅ Quality parameters initialized successfully!');
    } catch (e) {
      print('❌ Error initializing quality parameters: $e');
    }
  }
  
  static Future<void> _initializeBodyParts() async {
    // 1. Front pillar upper outer
    await _ds.insertQualityParameters(
      category: 'Body parts',
      product: 'Front pillar upper outer',
      parameters: [
        {
          'name': 'Material thickness',
          'standard': '2.5 mm',
          'tolerance': '±0.1 mm',
          'type': 'numeric',
          'unit': 'mm',
          'min_value': 2.4,
          'max_value': 2.6,
        },
        {
          'name': 'Length dimension',
          'standard': '1200 mm',
          'tolerance': '±2 mm',
          'type': 'numeric',
          'unit': 'mm',
          'min_value': 1198,
          'max_value': 1202,
        },
        {
          'name': 'Width dimension',
          'standard': '350 mm',
          'tolerance': '±1 mm',
          'type': 'numeric',
          'unit': 'mm',
          'min_value': 349,
          'max_value': 351,
        },
        {
          'name': 'Visual defects (dents)',
          'standard': 'No defects',
          'type': 'boolean',
        },
        {
          'name': 'Mounting hole position',
          'standard': 'Within ±0.3 mm from datum',
          'type': 'numeric',
          'unit': 'mm',
        },
        {
          'name': 'Surface finish',
          'standard': 'Smooth, no scratches',
          'type': 'boolean',
        },
      ],
    );
    
    // 2. Cowl assembly
    await _ds.insertQualityParameters(
      category: 'Body parts',
      product: 'Cowl assembly',
      parameters: [
        {
          'name': 'Assembly height',
          'standard': '150 mm',
          'tolerance': '±1.5 mm',
          'type': 'numeric',
          'unit': 'mm',
        },
        {
          'name': 'Weld quality',
          'standard': 'Continuous, no gaps',
          'type': 'boolean',
        },
        {
          'name': 'Component alignment',
          'standard': 'Within ±0.5 mm',
          'type': 'numeric',
          'unit': 'mm',
        },
        {
          'name': 'Surface paint',
          'standard': 'Even coating, no bubbles',
          'type': 'boolean',
        },
        {
          'name': 'Fastener torque',
          'standard': '25 Nm',
          'tolerance': '±2 Nm',
          'type': 'numeric',
          'unit': 'Nm',
        },
      ],
    );
  }
  
  static Future<void> _initializeFuelSystemParts() async {
    // 1. Fuel inlet pipe
    await _ds.insertQualityParameters(
      category: 'Fuel system parts',
      product: 'Fuel inlet pipe',
      parameters: [
        {
          'name': 'Wall thickness',
          'standard': '1.2 mm',
          'tolerance': '±0.1 mm',
          'type': 'numeric',
          'unit': 'mm',
        },
        {
          'name': 'Inner diameter',
          'standard': '8.5 mm',
          'tolerance': '±0.05 mm',
          'type': 'numeric',
          'unit': 'mm',
        },
        {
          'name': 'Pressure test (3 bar)',
          'standard': 'No leakage',
          'type': 'boolean',
        },
        {
          'name': 'Visual defects',
          'standard': 'No dents/cracks',
          'type': 'boolean',
        },
        {
          'name': 'Material verification',
          'standard': 'Stainless Steel 304',
          'type': 'text',
        },
        {
          'name': 'Bend radius',
          'standard': '50 mm',
          'tolerance': '±2 mm',
          'type': 'numeric',
          'unit': 'mm',
        },
      ],
    );
    
    // 2. Canister
    await _ds.insertQualityParameters(
      category: 'Fuel system parts',
      product: 'Canister',
      parameters: [
        {
          'name': 'Capacity',
          'standard': '2.0 liters',
          'tolerance': '±0.1 liters',
          'type': 'numeric',
          'unit': 'L',
        },
        {
          'name': 'Pressure rating',
          'standard': '5 bar minimum',
          'type': 'numeric',
          'unit': 'bar',
        },
        {
          'name': 'Leak test',
          'standard': 'No bubbles in water test',
          'type': 'boolean',
        },
        {
          'name': 'Mounting bracket alignment',
          'standard': 'Within ±1.0 mm',
          'type': 'numeric',
          'unit': 'mm',
        },
      ],
    );
  }
  
  static Future<void> _initializeExhaustSystemParts() async {
    // 1. Exhaust manifold
    await _ds.insertQualityParameters(
      category: 'Exhaust system parts',
      product: 'Exhaust manifold',
      parameters: [
        {
          'name': 'Flange flatness',
          'standard': 'Within 0.1 mm',
          'type': 'numeric',
          'unit': 'mm',
        },
        {
          'name': 'Weld penetration',
          'standard': 'Full penetration',
          'type': 'boolean',
        },
        {
          'name': 'Port diameter',
          'standard': '42 mm',
          'tolerance': '±0.2 mm',
          'type': 'numeric',
          'unit': 'mm',
        },
        {
          'name': 'Heat resistance',
          'standard': 'Withstands 800°C',
          'type': 'text',
        },
        {
          'name': 'Surface cracks',
          'standard': 'No cracks visible',
          'type': 'boolean',
        },
      ],
    );
    
    // 2. Exhaust system assembly
    await _ds.insertQualityParameters(
      category: 'Exhaust system parts',
      product: 'Exhaust system',
      parameters: [
        {
          'name': 'Overall length',
          'standard': '2500 mm',
          'tolerance': '±5 mm',
          'type': 'numeric',
          'unit': 'mm',
        },
        {
          'name': 'Catalyst position',
          'standard': 'Within ±10 mm from spec',
          'type': 'numeric',
          'unit': 'mm',
        },
        {
          'name': 'Hanger alignment',
          'standard': 'All hangers aligned',
          'type': 'boolean',
        },
        {
          'name': 'Joint tightness',
          'standard': 'No exhaust leaks',
          'type': 'boolean',
        },
      ],
    );
  }
  
  static Future<void> _initializeSuspensionParts() async {
    // 1. Front suspension sub-frame
    await _ds.insertQualityParameters(
      category: 'Suspension parts',
      product: 'Front suspension sub-frame',
      parameters: [
        {
          'name': 'Material thickness',
          'standard': '4.0 mm',
          'tolerance': '±0.2 mm',
          'type': 'numeric',
          'unit': 'mm',
        },
        {
          'name': 'Bush hole diameter',
          'standard': '25 mm',
          'tolerance': '±0.1 mm',
          'type': 'numeric',
          'unit': 'mm',
        },
        {
          'name': 'Welding length',
          'standard': 'Continuous 100%',
          'type': 'boolean',
        },
        {
          'name': 'Surface treatment',
          'standard': 'Powder coated',
          'type': 'text',
        },
        {
          'name': 'Dimensional accuracy',
          'standard': 'Within ±1.5 mm of CAD',
          'type': 'numeric',
          'unit': 'mm',
        },
      ],
    );
    
    // 2. Trailing arm
    await _ds.insertQualityParameters(
      category: 'Suspension parts',
      product: 'Trailing arm',
      parameters: [
        {
          'name': 'Arm length',
          'standard': '450 mm',
          'tolerance': '±2 mm',
          'type': 'numeric',
          'unit': 'mm',
        },
        {
          'name': 'Bushing parallelism',
          'standard': 'Within 0.5°',
          'type': 'numeric',
          'unit': 'degrees',
        },
        {
          'name': 'Weight',
          'standard': '3.2 kg',
          'tolerance': '±0.1 kg',
          'type': 'numeric',
          'unit': 'kg',
        },
        {
          'name': 'Heat treatment',
          'standard': 'Hardness HRC 35-40',
          'type': 'text',
        },
      ],
    );
  }
  
  static Future<void> _initializeInteriorParts() async {
    // Instrument panel reinforcement
    await _ds.insertQualityParameters(
      category: 'Interior parts',
      product: 'Instrument panel reinforcement',
      parameters: [
        {
          'name': 'Sheet thickness',
          'standard': '1.5 mm',
          'tolerance': '±0.1 mm',
          'type': 'numeric',
          'unit': 'mm',
        },
        {
          'name': 'Hole pattern accuracy',
          'standard': 'All holes within ±0.3 mm',
          'type': 'numeric',
          'unit': 'mm',
        },
        {
          'name': 'Surface finish',
          'standard': 'No sharp edges',
          'type': 'boolean',
        },
        {
          'name': 'Bracket alignment',
          'standard': 'All brackets perpendicular',
          'type': 'boolean',
        },
        {
          'name': 'Weight',
          'standard': '2.8 kg',
          'tolerance': '±0.05 kg',
          'type': 'numeric',
          'unit': 'kg',
        },
      ],
    );
  }
}