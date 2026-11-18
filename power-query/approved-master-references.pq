let
    Requests = Table.TransformColumns(Table.TransformColumnTypes(RequestSource, {{"Revision", Int64.Type}}), {{"SubmittedDate", each if Value.Is(_, type date) then _ else if Value.Is(_, type datetime) then Date.From(_) else Date.From(DateTimeZone.FromText(Text.From(_))), type date}}),
    Decisions = Table.TransformColumnTypes(DecisionSource, {{"Revision", Int64.Type}}),
    RequestKeys = Table.Group(Requests, {"RequestId", "Revision"}, {{"Rows", each Table.RowCount(_), Int64.Type}}),
    DecisionKeys = Table.Group(Decisions, {"RequestId", "Revision"}, {{"Rows", each Table.RowCount(_), Int64.Type}}),
    ValidRequests = if Table.RowCount(Table.SelectRows(RequestKeys, each [Rows] <> 1)) > 0 then error "Duplicate request revision" else Requests,
    ValidDecisions = if Table.RowCount(Table.SelectRows(DecisionKeys, each [Rows] <> 1)) > 0 then error "Multiple decisions require reconciliation" else Decisions,
    Latest = Table.Group(ValidRequests, {"RequestId"}, {{"Revision", each List.Max([Revision]), Int64.Type}}),
    CurrentJoin = Table.NestedJoin(ValidRequests, {"RequestId", "Revision"}, Latest, {"RequestId", "Revision"}, "Current", JoinKind.Inner),
    Current = Table.RemoveColumns(CurrentJoin, {"Current"}),
    // Placeholder tool names and department rules are explicit demo assumptions.
    Eligible = Table.SelectRows(Current, each
        [Description] <> null and Text.Trim([Description]) <> "" and
        ([Kind] = "Macro" or ([Kind] = "Workflow" and
        List.Contains({"Operations", "Analytics"}, [Department]) and
        List.Count(List.Intersect({Text.Split(if [SelectedTools] = null then "" else [SelectedTools], ";"), {"Demo Local File Tool", "Demo Unsupported Tool"}})) = 0))),
    Joined = Table.NestedJoin(Eligible, {"RequestId", "Revision"}, ValidDecisions, {"RequestId", "Revision"}, "Certification", JoinKind.Inner),
    Expanded = Table.ExpandTableColumn(Joined, "Certification", {"Decision", "Certifier", "Reason"}),
    Approved = Table.SelectRows(Expanded, each [Decision] = "Approve"),
    Due = Table.AddColumn(Approved, "RecertifyBy", each if [Kind] = "Macro" then null else if [Department] = "Operations" then Date.EndOfYear([SubmittedDate]) else Date.AddMonths([SubmittedDate], 12), type date)
in
    Table.SelectColumns(Due, {"RequestId", "Decision", "RecertifyBy", "Kind", "Department", "Certifier"})
