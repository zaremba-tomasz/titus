import React from 'react'
import PropTypes from 'prop-types'
import TableHead from '@material-ui/core/TableHead'
import TableRow from '@material-ui/core/TableRow'

const HeaderRow = ({ children }) => (
  <TableHead>
    <TableRow>{children}</TableRow>
  </TableHead>
)

HeaderRow.propTypes = {
  children: PropTypes.node
}

export default HeaderRow
