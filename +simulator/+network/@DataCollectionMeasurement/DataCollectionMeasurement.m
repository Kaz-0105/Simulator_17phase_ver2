classdef DataCollectionMeasurement < utils.class.Common
    properties
        Config;
        DataCollectionMeasurements;
        Road;
    end

    properties
        id;
        point_id;
        objective;
        Vissim;
    end

    methods 
        function obj = DataCollectionMeasurement(DataCollectionMeasurements, id)
            % ConfigクラスとDataCollectionMeasurementsクラスを設定
            obj.Config = DataCollectionMeasurements.get('Config');
            obj.DataCollectionMeasurements = DataCollectionMeasurements;

            % idを設定
            obj.id = id;

            % VissimのCOMオブジェクトを設定
            obj.create('Vissim');

            % Roadクラスを設定
            obj.create('Road');
        end
    end

    methods
        create(obj, property_name);
    end
end