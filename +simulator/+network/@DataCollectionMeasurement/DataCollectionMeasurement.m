classdef DataCollectionMeasurement < utils.class.Common
    properties
        Config;
        DataCollectionMeasurements;
    end

    properties
        id;
        type;
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

            % Linkクラス関連の設定
            obj.create('Links');

            % Roadクラス関連の設定
            obj.create('Roads');
        end
    end

    methods
        create(obj, property_name);
    end
end