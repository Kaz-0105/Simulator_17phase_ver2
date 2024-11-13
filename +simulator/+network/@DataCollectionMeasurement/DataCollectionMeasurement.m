classdef DataCollectionMeasurement < utils.class.Common
    properties
        Config;
        DataCollectionMeasurements;
        Road;
    end

    properties
        id;
        point_id;
        link_id;
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

            % point_idを設定
            obj.create('point_id');

            % from_link_idを設定
            obj.create('from_link_id');
        end
    end

    methods
        create(obj, property_name);
    end
end