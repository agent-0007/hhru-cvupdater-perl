use utf8;
package CVUpdater::DB::Schema::Result::Resume;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CVUpdater::DB::Schema::Result::Resume

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<resumes>

=cut

__PACKAGE__->table("resumes");

=head1 ACCESSORS

=head2 id

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 user_id

  data_type: (empty string)
  is_foreign_key: 1
  is_nullable: 1

=head2 title

  data_type: 'nvarchar'
  is_nullable: 1
  size: 400

=head2 updated_at

  data_type: 'datetime'
  is_nullable: 1

=head2 last_update_int

  data_type: 'integer'
  is_nullable: 1

=head2 last_update_text

  data_type: 'varchar'
  is_nullable: 1
  size: 400

=head2 will_update

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "user_id",
  { data_type => "", is_foreign_key => 1, is_nullable => 1 },
  "title",
  { data_type => "nvarchar", is_nullable => 1, size => 400 },
  "updated_at",
  { data_type => "datetime", is_nullable => 1 },
  "last_update_int",
  { data_type => "integer", is_nullable => 1 },
  "last_update_text",
  { data_type => "varchar", is_nullable => 1, size => 400 },
  "will_update",
  { data_type => "integer", is_nullable => 1, default_value => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<CVUpdater::DB::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "CVUpdater::DB::Schema::Result::User",
  { mail => "user_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-04-17 20:59:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uI794CWE3QGR+MGXXjleEg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
