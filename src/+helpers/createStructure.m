function structure = createStructure(values, fields)
    %{
        Create a structure with names in fields and values in values
    %}
    rep_values = repmat(values, 1, numel(fields));
    structure = cell2struct(rep_values, fields, 1);
end